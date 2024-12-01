// Copyright (C) 2023 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

#ifndef RHIPROMPTERINSTANTIATOR_H
#define RHIPROMPTERINSTANTIATOR_H

#include <QtQuick/QQuickItem>
#include <QtQuick/QQuickWindow>

class PrompterRenderer;

//! [0]
class RhiPrompterInstantiator : public QQuickItem
{
    Q_OBJECT
    Q_PROPERTY(qreal t READ t WRITE setT NOTIFY tChanged)
    QML_ELEMENT

public:
    RhiPrompterInstantiator();

    qreal t() const { return m_t; }
    void setT(qreal t);

signals:
    void tChanged();

public slots:
    void sync();
    void cleanup();

private slots:
    void handleWindowChanged(QQuickWindow *win);

private:
    void releaseResources() override;

    qreal m_t = 0;
    PrompterRenderer *m_renderer = nullptr;
};
//! [0]

#endif
