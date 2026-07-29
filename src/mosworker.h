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

#include <memory>

#include "mossessionsettings.h"

class QTimer;

// The MOS protocol engine. Lives on the dedicated MOS thread owned by
// MosInputSource and is the only part of QPrompt that touches ImaginaryMOS
// (its headers appear in mosworker.cpp alone). The engine is pull-mode: a
// single-shot timer drives pump → poll → drain, re-armed from the library's
// nextDeadline() with a small floor so inbound frames are picked up promptly.
// All communication with the rest of the app is queued signals/slots carrying
// Qt value types only.
class MosWorker : public QObject
{
    Q_OBJECT
public:
    explicit MosWorker(QObject *parent = nullptr);
    ~MosWorker() override;

    // Status values mirror MosInputSource::Status; kept as ints on this side
    // of the thread boundary so the worker does not depend on the facade.
    enum Status { Disabled = 0, Connecting = 1, Connected = 2, Error = 3 };

    // Called by ControlBridge (mosworker.cpp) during poll(); public because
    // the bridge is not a member and signals cannot be emitted externally.
    void reportCtrl(int command, int scope, const QString &roID, const QString &storyID, const QString &itemID);
    void reportItemCue(const QString &roID, const QString &storyID, const QString &itemID, const QString &eventType, const QString &eventTime);

public slots:
    void startSession(const MosSessionSettings &settings);
    void stopSession();
    // Seam for outbound roItemCue: fires when the read line passes a marker.
    // Until Profile 4 story ingestion gives markers a MOS identity there is
    // nothing meaningful to send, so this only logs.
    void onMarkerPassed(int index, const QString &name);

signals:
    void statusChanged(int status, const QString &message);
    void peerInfoChanged(const QString &description);
    // Profile 5 roCtrl: command is imos CtrlCommand (0 Ready, 1 Execute,
    // 2 Pause, 3 Stop, 4 Signal), scope is imos CtrlScope (0 RO, 1 story,
    // 2 item); ID fields are empty below the addressed scope.
    void ctrlCommand(int command, int scope, const QString &roID, const QString &storyID, const QString &itemID);
    void itemCueReceived(const QString &roID, const QString &storyID, const QString &itemID, const QString &eventType, const QString &eventTime);

private slots:
    void tick();

private:
    struct Engine;
    void scheduleTick();
    void updateStatus();
    void setStatus(int status, const QString &message);

    std::unique_ptr<Engine> m_engine;
    QTimer *m_timer;
};
