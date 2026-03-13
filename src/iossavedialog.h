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
#include <QQmlEngine>
#include <QTemporaryDir>
#include <QUrl>

class IosSaveDialog : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

public:
    explicit IosSaveDialog(QObject *parent = nullptr);

    static IosSaveDialog *instance();
    static IosSaveDialog *create(QQmlEngine *engine, QJSEngine *);

    Q_INVOKABLE void saveDocument(const QString &htmlContent, const QString &suggestedName);

Q_SIGNALS:
    void accepted(const QUrl &fileUrl);
    void rejected();

private:
    static IosSaveDialog *s_instance;
    QTemporaryDir m_tempDir;
};
