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

#include <QMetaType>
#include <QString>

// Everything MosWorker needs to open one MOS session, as a plain value type
// so it can ride a queued signal across the GUI/MOS thread boundary. Carries
// no ImaginaryMOS types; the transport field holds a
// MosInputSource::Transport value.
struct MosSessionSettings
{
    QString mosID;
    QString ncsID;
    QString url;
    int transport = 0;
    bool utf8Wire = false;
    QString username;
    QString password;
};
Q_DECLARE_METATYPE(MosSessionSettings)
