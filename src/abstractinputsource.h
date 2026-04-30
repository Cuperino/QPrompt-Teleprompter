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

#include <QObject>

class AppController;

class AbstractInputSource : public QObject
{
    Q_OBJECT
public:
    AbstractInputSource() = delete;
    AbstractInputSource(AppController *controller);
signals:
    void togglePrompter(bool checked=false);
    void increaseVelocity(bool checked=false);
    void decreaseVelocity(bool checked=false);
    void pause(bool checked=false);
    void stop(bool checked=false);
    void setVelocity(int velocity);
    void reverse(bool checked=false);
    void rewind(bool checked);
    void fastForward(bool checked);
    void skipBackwards(bool checked=false);
    void skipForwards(bool checked=false);
    void previousMarker(bool checked=false);
    void nextMarker(bool checked=false);
protected:
    AppController *m_controller;
    virtual void m_initializeSource();
};
