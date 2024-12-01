// Copyright (C) 2023 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

#include "rhiprompterinstantiator.h"
#include <QtQuick/QQuickWindow>
#include <QtCore/QFile>
#include <QtCore/QRunnable>

#include <rhi/qrhi.h>

class PrompterRenderer : public QObject
{
    Q_OBJECT
public:
    void setT(qreal t) { m_t = t; }
    void setWindow(QQuickWindow *window) { m_window = window; }

public slots:
    void frameStart();
    void mainPassRecordingStart();

private:
    qreal m_t = 0;
    QQuickWindow *m_window;
    QShader m_vertexShader;
    QShader m_fragmentShader;
    std::unique_ptr<QRhiBuffer> m_vertexBuffer;
    std::unique_ptr<QRhiBuffer> m_uniformBuffer;
    std::unique_ptr<QRhiShaderResourceBindings> m_srb;
    std::unique_ptr<QRhiGraphicsPipeline> m_pipeline;
};

//! [init]
RhiPrompterInstantiator::RhiPrompterInstantiator()
{
    connect(this, &QQuickItem::windowChanged, this, &RhiPrompterInstantiator::handleWindowChanged);
}

void RhiPrompterInstantiator::handleWindowChanged(QQuickWindow *win)
{
    if (win) {
        connect(win, &QQuickWindow::beforeSynchronizing, this, &RhiPrompterInstantiator::sync, Qt::DirectConnection);
        connect(win, &QQuickWindow::sceneGraphInvalidated, this, &RhiPrompterInstantiator::cleanup, Qt::DirectConnection);
        // Ensure we start with a cleared transparent background.
        win->setColor(Qt::transparent);
    }
}
//! [init]

// The safe way to release custom graphics resources is to both connect to
// sceneGraphInvalidated() and implement releaseResources(). To support
// threaded render loops the latter performs the PrompterRenderer destruction
// via scheduleRenderJob(). Note that the RhiPrompterInstantiator may be gone by the time
// the QRunnable is invoked.

void RhiPrompterInstantiator::cleanup()
{
    // This function is invoked on the render thread, if there is one.

    delete m_renderer;
    m_renderer = nullptr;
}

class CleanupJob : public QRunnable
{
public:
    CleanupJob(PrompterRenderer *renderer) : m_renderer(renderer) { }
    void run() override { delete m_renderer; }
private:
    PrompterRenderer *m_renderer;
};

void RhiPrompterInstantiator::releaseResources()
{
    window()->scheduleRenderJob(new CleanupJob(m_renderer), QQuickWindow::BeforeSynchronizingStage);
    m_renderer = nullptr;
}

void RhiPrompterInstantiator::setT(qreal t)
{
    if (t == m_t)
        return;
    m_t = t;
    emit tChanged();
    if (window())
        window()->update();
}

//! [sync]
void RhiPrompterInstantiator::sync()
{
    // This function is invoked on the render thread, if there is one.

    if (!m_renderer) {
        m_renderer = new PrompterRenderer;
        // Initializing resources is done before starting to record the
        // renderpass, regardless of wanting an underlay or overlay.
        connect(window(), &QQuickWindow::beforeRendering, m_renderer, &PrompterRenderer::frameStart, Qt::DirectConnection);
        // Here we want an underlay and therefore connect to
        // beforeRenderPassRecording. Changing to afterRenderPassRecording
        // would render the squircle on top (overlay).
        connect(window(), &QQuickWindow::beforeRenderPassRecording, m_renderer, &PrompterRenderer::mainPassRecordingStart, Qt::DirectConnection);
    }
    m_renderer->setT(m_t);
    m_renderer->setWindow(window());
}
//! [sync]

static QShader getShader(const QString &name)
{
    QFile f(name);
    if (f.open(QIODevice::ReadOnly))
        return QShader::fromSerialized(f.readAll());

    return QShader();
}

static const float vertices[] = {
    -1, -1,
     1, -1,
    -1,  1,
     1,  1
};

//! [frame-start]
void PrompterRenderer::frameStart()
{
    // This function is invoked on the render thread, if there is one.

    QRhi *rhi = m_window->rhi();
    if (!rhi) {
        qWarning("QQuickWindow is not using QRhi for rendering");
        return;
    }
    QRhiSwapChain *swapChain = m_window->swapChain();
    if (!swapChain) {
        qWarning("No QRhiSwapChain?");
        return;
    }
    QRhiResourceUpdateBatch *resourceUpdates = rhi->nextResourceUpdateBatch();

    if (!m_pipeline) {
        m_vertexShader = getShader(QLatin1String(":/qt/qml/com/cuperino/qprompt/shaders/squircle_rhi.vert.qsb"));
        if (!m_vertexShader.isValid())
            qWarning("Failed to load vertex shader; rendering will be incorrect");

        m_fragmentShader = getShader(QLatin1String(":/qt/qml/com/cuperino/qprompt/shaders/squircle_rhi.frag.qsb"));
        if (!m_fragmentShader.isValid())
            qWarning("Failed to load fragment shader; rendering will be incorrect");

        m_vertexBuffer.reset(rhi->newBuffer(QRhiBuffer::Immutable, QRhiBuffer::VertexBuffer, sizeof(vertices)));
        m_vertexBuffer->create();
        resourceUpdates->uploadStaticBuffer(m_vertexBuffer.get(), vertices);

        const quint32 UBUF_SIZE = 4 + 4; // 2 floats
        m_uniformBuffer.reset(rhi->newBuffer(QRhiBuffer::Dynamic, QRhiBuffer::UniformBuffer, UBUF_SIZE));
        m_uniformBuffer->create();

        float yDir = rhi->isYUpInNDC() ? 1.0f : -1.0f;
        resourceUpdates->updateDynamicBuffer(m_uniformBuffer.get(), 4, 4, &yDir);

        m_srb.reset(rhi->newShaderResourceBindings());
        const auto visibleToAll = QRhiShaderResourceBinding::VertexStage | QRhiShaderResourceBinding::FragmentStage;
        m_srb->setBindings({
            QRhiShaderResourceBinding::uniformBuffer(0, visibleToAll, m_uniformBuffer.get())
        });
        m_srb->create();

        QRhiVertexInputLayout inputLayout;
        inputLayout.setBindings({
            { 2 * sizeof(float) }
        });
        inputLayout.setAttributes({
            { 0, 0, QRhiVertexInputAttribute::Float2, 0 }
        });

        m_pipeline.reset(rhi->newGraphicsPipeline());
        m_pipeline->setTopology(QRhiGraphicsPipeline::TriangleStrip);
        QRhiGraphicsPipeline::TargetBlend blend;
        blend.enable = true;
        blend.srcColor = QRhiGraphicsPipeline::SrcAlpha;
        blend.srcAlpha = QRhiGraphicsPipeline::SrcAlpha;
        blend.dstColor = QRhiGraphicsPipeline::One;
        blend.dstAlpha = QRhiGraphicsPipeline::One;
        m_pipeline->setTargetBlends({ blend });
        m_pipeline->setShaderStages({
            { QRhiShaderStage::Vertex, m_vertexShader },
            { QRhiShaderStage::Fragment, m_fragmentShader }
        });
        m_pipeline->setVertexInputLayout(inputLayout);
        m_pipeline->setShaderResourceBindings(m_srb.get());
        m_pipeline->setRenderPassDescriptor(swapChain->currentFrameRenderTarget()->renderPassDescriptor());
        m_pipeline->create();
    }

    float t = m_t;
    resourceUpdates->updateDynamicBuffer(m_uniformBuffer.get(), 0, 4, &t);

    swapChain->currentFrameCommandBuffer()->resourceUpdate(resourceUpdates);
}
//! [frame-start]

//! [frame-render]
void PrompterRenderer::mainPassRecordingStart()
{
    // This function is invoked on the render thread, if there is one.

    QRhi *rhi = m_window->rhi();
    QRhiSwapChain *swapChain = m_window->swapChain();
    if (!rhi || !swapChain)
        return;

    const QSize outputPixelSize = swapChain->currentFrameRenderTarget()->pixelSize();
    QRhiCommandBuffer *cb = m_window->swapChain()->currentFrameCommandBuffer();
    cb->setViewport({ 0.0f, 0.0f, float(outputPixelSize.width()), float(outputPixelSize.height()) });
    cb->setGraphicsPipeline(m_pipeline.get());
    cb->setShaderResources();
    const QRhiCommandBuffer::VertexInput vbufBinding(m_vertexBuffer.get(), 0);
    cb->setVertexInput(0, 1, &vbufBinding);
    cb->draw(4);
}
//! [frame-render]

#include "rhiprompterinstantiator.moc"
