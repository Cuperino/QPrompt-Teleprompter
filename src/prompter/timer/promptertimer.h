/****************************************************************************
 **
 ** QPrompt
 ** Copyright (C) 2020 Javier O. Cordero Pérez
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

#ifndef TIMER_H
#define TIMER_H

// #include <QTime>
#include <QObject>
#include <QTimer>
#include <QTimerEvent> 
#include <QString>
#include <iostream>

/**
 * @todo write docs
 */
class PrompterTimer : public QObject
{
    Q_OBJECT
    
    Q_PROPERTY(QString chronometer READ chronometer WRITE setChronometer NOTIFY chronometerChanged)
    Q_PROPERTY(QString eta READ eta WRITE setETA NOTIFY etaChanged)
    
public:
    /**
     * Default constructor
     */
    explicit PrompterTimer(QObject *parent = nullptr);

signals:
    void chronometerChanged();
    void etaChanged();
    
public slots:
    void start();
    void stop();
    void reset();
    void toggle(bool value);

// protected:
//     void timerEvent(QTimerEvent *)
//     {
//         if(mRunning)
//         {
//             qint64 ms = mStartTime.msecsTo(QTime::currentTime());
//             int h = ms / 1000 / 60 / 60;
//             int m = (ms / 1000 / 60) - (h * 60);
//             int s = (ms / 1000) - (m * 60);
//             ms = ms - (s * 1000) - (m * 60000) - (h * 3600000);
//             QString diff = QString("%1:%2:%3:%4").
//             arg(h, 3, 10, 0).
//             arg(m, 2, 10, 0).
//             arg(s, 2, 10, 0).
//             arg(ms, 3, 10, 0);
//             //mLabel->setText(diff);
//         }
//     }
    
private:
    // Tut
    //QTimer m_timer;
    //QElapsedTimer m_watch;
    QString m_chronometer;
    QString m_eta;

    QString chronometer();
    QString eta();
    void setChronometer(QString value);
    void setETA(QString value);
    
    // Git
//     bool mRunning;
//     QTime mStartTime;
//     const QChar zero;    

};
#endif // PROMPTERTIMER_H
