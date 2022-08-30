/****************************************************************************
 **
 ** QPrompt
 ** Copyright (C) 2022 Javier O. Cordero Pérez
 **
 ** This file is part of QPrompt.
 **
 ** This program is free software: you can redistribute it and/or modify
 ** it under the terms of the GNU General Public License as published by
 ** the Free Software Foundation, version 3 of the License.
 **
 ** This program is distributed in the hope that it will be useful,
 ** but WITHOUT ANY WARRANTY; without even the implied warranty of
 ** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 ** GNU General Public License for more details.
 **
 ** You should have received a copy of the GNU General Public License
 ** along with this program.  If not, see <http://www.gnu.org/licenses/>.
 **
 ****************************************************************************/

#include "prompterwindow.h"

#include <QSurfaceFormat>
#include <QOpenGLContext>
#include <QOpenGLFunctions>

#include <QQuickWindow>
#include <QQuickRenderControl>
#include <QQuickItem>

#include <QQmlEngine>
#include <QQmlComponent>
#include <QQmlContext>

#include <QTimer>

PrompterWindow::PrompterWindow(QQmlEngine *engine, QWindow *parent)
    : QPromptWindow(engine, parent)
{
//    // set the window up
//    setSurfaceType(QSurface::OpenGLSurface);

//    QSurfaceFormat format;
//    format.setAlphaBufferSize(8);
//    format.setMajorVersion(3);
//    format.setMinorVersion(3);
////    format.setProfile(QSurfaceFormat::CoreProfile);
//    format.setDepthBufferSize(24);
//    format.setStencilBufferSize(8);
//    format.setSamples(4);

//    setFormat(format);
//    create();

//    // create the GL context

//    m_context = new QOpenGLContext(this);
//    m_context->setFormat(format);
//    if (!m_context->create())
//        qFatal("Unable to create context");

//    m_context->makeCurrent(this);

//    // set up QtQuick

//    m_renderControl = new QQuickRenderControl(this);
//    m_quickWindow = new QQuickWindow(m_renderControl);
//    m_quickWindow->setClearBeforeRendering(false);

//    // try to "batch" multiple scene changed signals in one sync
//    QTimer *sceneSyncTimer = new QTimer(this);
//    sceneSyncTimer->setInterval(5);
//    sceneSyncTimer->setSingleShot(true);
//    connect(sceneSyncTimer, &QTimer::timeout,
//            this, &QPromptWindow::syncScene);

//    connect(m_renderControl, &QQuickRenderControl::sceneChanged,
//            sceneSyncTimer, static_cast<void (QTimer::*)()>(&QTimer::start));

//    connect(m_renderControl, &QQuickRenderControl::renderRequested,
//            this, &QPromptWindow::draw);

//    m_renderControl->initialize(m_context);


//    // load a QML scene "manually"
//    //QQmlEngine *engine = new QQmlEngine(this);

//    if (!engine->incubationController())
//        engine->setIncubationController(m_quickWindow->incubationController());

//    //engine->rootContext()->setContextProperty("_camera", m_camera);
//    m_qmlComponent = new QQmlComponent(engine, this);

//    connect(m_qmlComponent, &QQmlComponent::statusChanged,
//            this, &QPromptWindow::onQmlComponentLoadingComplete);

//    m_qmlComponent->loadUrl(QUrl("qrc:///PrompterWindowContents.qml"));


//    // also, just for the sake of it, trigger a redraw every 500 ms no matter what
//    QTimer *redrawTimer = new QTimer(this);
//    connect(redrawTimer, &QTimer::timeout, this, &QPromptWindow::draw);
//    redrawTimer->start(500);
}

