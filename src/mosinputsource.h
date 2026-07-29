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

#include "abstractinputsource.h"
#include "mossessionsettings.h"

#include <QQmlEngine>

class QThread;
class MosWorker;

// MOS newsroom integration facade. Lives on the GUI thread and is exposed to
// QML as AppController.mos; owns the dedicated MOS thread that runs the
// MosWorker protocol engine. Inbound Profile 5 roCtrl commands surface as
// AbstractInputSource signals, so the prompter reacts to the newsroom the
// same way it reacts to hotkeys.
class MosInputSource : public AbstractInputSource
{
    Q_OBJECT
    QML_ELEMENT
    QML_UNCREATABLE("MosInputSource is accessed through AppController.mos")

public:
    enum class Status { Disabled, Connecting, Connected, Error };
    Q_ENUM(Status)
    enum class Transport { Ws40, Ws40Passive, Tcp28 };
    Q_ENUM(Transport)

    Q_PROPERTY(bool enabled READ enabled WRITE setEnabled NOTIFY enabledChanged)
    Q_PROPERTY(Status status READ status NOTIFY statusChanged)
    Q_PROPERTY(QString statusMessage READ statusMessage NOTIFY statusChanged)
    Q_PROPERTY(QString peerDescription READ peerDescription NOTIFY peerChanged)
    Q_PROPERTY(QString mosID READ mosID WRITE setMosID NOTIFY configChanged)
    Q_PROPERTY(QString ncsID READ ncsID WRITE setNcsID NOTIFY configChanged)
    Q_PROPERTY(QString endpointUrl READ endpointUrl WRITE setEndpointUrl NOTIFY configChanged)
    Q_PROPERTY(Transport transport READ transport WRITE setTransport NOTIFY configChanged)
    Q_PROPERTY(bool utf8Wire READ utf8Wire WRITE setUtf8Wire NOTIFY configChanged)
    Q_PROPERTY(QString username READ username WRITE setUsername NOTIFY configChanged)
    Q_PROPERTY(QString password READ password WRITE setPassword NOTIFY configChanged)
    // Legacy MOS 2.8 TCP is compiled on desktop platforms only.
    Q_PROPERTY(bool tcp28Available READ tcp28Available CONSTANT)

    explicit MosInputSource(AppController *controller);
    ~MosInputSource() override;

    bool enabled() const;
    void setEnabled(bool enabled);
    Status status() const;
    QString statusMessage() const;
    QString peerDescription() const;
    QString mosID() const;
    void setMosID(const QString &mosID);
    QString ncsID() const;
    void setNcsID(const QString &ncsID);
    QString endpointUrl() const;
    void setEndpointUrl(const QString &url);
    Transport transport() const;
    void setTransport(Transport transport);
    bool utf8Wire() const;
    void setUtf8Wire(bool utf8Wire);
    QString username() const;
    void setUsername(const QString &username);
    QString password() const;
    void setPassword(const QString &password);
    bool tcp28Available() const;

    // Persist the pending configuration and restart the session with it.
    Q_INVOKABLE void applyAndReconnect();

signals:
    void enabledChanged();
    void statusChanged();
    void peerChanged();
    void configChanged();
    // GUI → MOS thread (queued)
    void startRequested(const MosSessionSettings &settings);
    void stopRequested();

protected:
    void m_initializeSource() override;

private slots:
    void onWorkerStatus(int status, const QString &message);
    void onPeerInfo(const QString &description);
    void onCtrlCommand(int command, int scope, const QString &roID, const QString &storyID, const QString &itemID);
    void onItemCue(const QString &roID, const QString &storyID, const QString &itemID, const QString &eventType, const QString &eventTime);
    void shutdown();

private:
    void m_startWorker();
    void m_loadSettings();
    void m_saveSettings() const;

    QThread *m_thread = nullptr;
    MosWorker *m_worker = nullptr;
    MosSessionSettings m_settings;
    bool m_enabled = false;
    Status m_status = Status::Disabled;
    QString m_statusMessage;
    QString m_peerDescription;
};
