/****************************************************************************
 **
 ** QPrompt
 ** Copyright (C) 2026 Javier O. Cordero Pérez
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

#pragma once

#include <QElapsedTimer>
#include <QQmlEngine>
#include <QQuickItem>
#include <QQuickWindow>
#include <QScreen>

class TimedItem : public QQuickItem
{
    Q_OBJECT
    QML_ELEMENT

    Q_PROPERTY(qint64 timeToDisplay READ timeToDisplay NOTIFY timeToDisplayChanged FINAL)
    Q_PROPERTY(int framesSkipped READ framesSkipped NOTIFY framesSkippedChanged FINAL)
    Q_PROPERTY(bool measuring READ measuring WRITE setMeasuring NOTIFY measuringChanged FINAL)

public:
    TimedItem(QQuickItem *parent = nullptr)
        : QQuickItem(parent)
        , m_elapsedTimer(new QElapsedTimer())
    {
        setVisible(false);
        QObject::connect(this, &QQuickItem::visibleChanged, this, &TimedItem::startMeasuringTimeToDisplay, Qt::DirectConnection);
        QObject::connect(this, &QQuickItem::windowChanged, this, &TimedItem::onWindowChanged);
    }

    ~TimedItem() override
    {
        delete m_elapsedTimer;
    }

    qint64 timeToDisplay() const
    {
        return m_timeToDisplay;
    }

    int framesSkipped() const
    {
        return m_framesSkipped;
    }

    bool measuring() const
    {
        return m_measuring;
    }

    void setMeasuring(bool measuring)
    {
        if (m_measuring == measuring)
            return;
        m_measuring = measuring;
        emit measuringChanged();
        if (m_measuring)
            connectFrameMonitor();
        else
            disconnectFrameMonitor();
    }

signals:
    void timeToDisplayChanged();
    void framesSkippedChanged();
    void measuringChanged();

private:
    void onWindowChanged(QQuickWindow *win)
    {
        if (m_connectedWindow) {
            QObject::disconnect(m_connectedWindow, &QQuickWindow::afterFrameEnd, this, &TimedItem::onFrameEnd);
            m_connectedWindow = nullptr;
        }
        if (m_measuring && win)
            connectFrameMonitor();
    }

    void connectFrameMonitor()
    {
        if (!window() || m_connectedWindow == window())
            return;
        if (m_connectedWindow)
            QObject::disconnect(m_connectedWindow, &QQuickWindow::afterFrameEnd, this, &TimedItem::onFrameEnd);
        m_connectedWindow = window();
        m_elapsedTimer->start();
        QObject::connect(m_connectedWindow, &QQuickWindow::afterFrameEnd, this, &TimedItem::onFrameEnd, Qt::DirectConnection);
    }

    void disconnectFrameMonitor()
    {
        if (m_connectedWindow) {
            QObject::disconnect(m_connectedWindow, &QQuickWindow::afterFrameEnd, this, &TimedItem::onFrameEnd);
            m_connectedWindow = nullptr;
        }
    }

    void onFrameEnd()
    {
        const qint64 elapsed = m_elapsedTimer->elapsed();
        m_elapsedTimer->start();

        qreal refreshRate = 60.0;
        if (window() && window()->screen())
            refreshRate = window()->screen()->refreshRate();
        const qreal frameTime = 1000.0 / refreshRate;

        // Frames are skipped when elapsed time exceeds one frame period
        const int skipped = qMax(0, static_cast<int>(elapsed / frameTime) - 1);
        if (skipped > 0) {
            m_framesSkipped += skipped;
            emit framesSkippedChanged();
        }
    }

    void startMeasuringTimeToDisplay()
    {
        if (isVisible()) {
            m_frameReady = false;
            QObject::connect(window(), &QQuickWindow::afterFrameEnd, this, &TimedItem::measure,
                             static_cast<Qt::ConnectionType>(Qt::DirectConnection | Qt::UniqueConnection));
            ensurePolished();
            m_elapsedTimer->start();
        }
    }

    void updatePolish() override
    {
        m_frameReady = true;
    }

    void measure()
    {
        if (m_frameReady) {
            m_timeToDisplay = m_elapsedTimer->elapsed();
            QObject::disconnect(window(), &QQuickWindow::afterFrameEnd, this, &TimedItem::measure);
            emit timeToDisplayChanged();

            // If continuous measuring is active, restart the frame monitor
            if (m_measuring)
                connectFrameMonitor();
        }
    }

    Q_INVOKABLE void resetFramesSkipped()
    {
        m_framesSkipped = 0;
        emit framesSkippedChanged();
    }

private:
    qint64 m_timeToDisplay = 0;
    int m_framesSkipped = 0;
    bool m_measuring = false;
    bool m_frameReady = false;
    QElapsedTimer *m_elapsedTimer;
    QQuickWindow *m_connectedWindow = nullptr;
};
