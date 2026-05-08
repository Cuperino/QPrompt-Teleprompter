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

class WasmIntegration : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_UNCREATABLE("WasmIntegration is only to be interfaced with through the AppController")
public:
    explicit WasmIntegration(QObject *parent = nullptr);
    Q_INVOKABLE void loadBackgroundImageTo(QObject *prompterBackground);
    Q_INVOKABLE void pickPointerImage(QObject *filenameField, QObject *sourceHolder, const QString &sourceProperty);
    Q_INVOKABLE void pickPointerQml(QObject *filenameField, QObject *sourceHolder, const QString &sourceProperty);
    Q_INVOKABLE void toggleBrowserFullscreen();
    Q_INVOKABLE void saveDocument(const QString &filename, const QString &content);
};
