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

#include "wasmintegration.h"

#include <QByteArray>
#include <QPointer>
#include <QString>
#include <QVariant>
#include <emscripten.h>

namespace {
constexpr int kTargetBackground = 0;
constexpr int kTargetText = 1;

QPointer<QObject> s_pendingBackground;
QPointer<QObject> s_pendingFilenameField;
QPointer<QObject> s_pendingSourceHolder;
QByteArray s_pendingSourceProperty;
}

extern "C" {
EMSCRIPTEN_KEEPALIVE
void qprompt_wasmFileReceived(const char *filename, const char *dataUrl, int targetKind)
{
    if (targetKind == kTargetBackground) {
        QPointer<QObject> background = s_pendingBackground;
        s_pendingBackground.clear();
        if (!background || !dataUrl || !*dataUrl)
            return;
        QMetaObject::invokeMethod(background.data(),
                                  "setBackgroundImage",
                                  Q_ARG(QVariant, QVariant::fromValue(QString::fromUtf8(dataUrl))));
    } else if (targetKind == kTargetText) {
        QPointer<QObject> field = s_pendingFilenameField;
        QPointer<QObject> holder = s_pendingSourceHolder;
        QByteArray prop = s_pendingSourceProperty;
        s_pendingFilenameField.clear();
        s_pendingSourceHolder.clear();
        s_pendingSourceProperty.clear();
        if (!filename || !dataUrl || !*dataUrl)
            return;
        if (field)
            field->setProperty("text", QString::fromUtf8(filename));
        if (holder && !prop.isEmpty())
            holder->setProperty(prop.constData(), QString::fromUtf8(dataUrl));
    }
}
}

EM_JS(void, qprompt_wasmPickFile, (const char *acceptCStr, int targetKind), {
    var accept = UTF8ToString(acceptCStr);
    var input = document.createElement('input');
    input.type = 'file';
    input.accept = accept;
    input.style.display = 'none';
    input.addEventListener('change', function(event) {
        var file = event.target.files && event.target.files[0];
        document.body.removeChild(input);
        if (!file)
            return;
        var reader = new FileReader();
        reader.onload = function() {
            var dataUrl = reader.result;
            var filename = file.name || '';
            var encoder = new TextEncoder();
            var nameBytes = encoder.encode(filename);
            var namePtr = _malloc(nameBytes.length + 1);
            HEAPU8.set(nameBytes, namePtr);
            HEAPU8[namePtr + nameBytes.length] = 0;
            var dataBytes = encoder.encode(dataUrl);
            var dataPtr = _malloc(dataBytes.length + 1);
            HEAPU8.set(dataBytes, dataPtr);
            HEAPU8[dataPtr + dataBytes.length] = 0;
            _qprompt_wasmFileReceived(namePtr, dataPtr, targetKind);
            _free(namePtr);
            _free(dataPtr);
        };
        reader.readAsDataURL(file);
    });
    document.body.appendChild(input);
    input.click();
});

WasmIntegration::WasmIntegration(QObject *parent) : QObject(parent)
{
}

void WasmIntegration::loadBackgroundImageTo(QObject *prompterBackground)
{
    if (!prompterBackground)
        return;
    s_pendingBackground = prompterBackground;
    qprompt_wasmPickFile("image/png, image/jpeg, image/gif, image/webp", kTargetBackground);
}

void WasmIntegration::pickPointerImage(QObject *filenameField, QObject *sourceHolder, const QString &sourceProperty)
{
    if (!filenameField || !sourceHolder || sourceProperty.isEmpty())
        return;
    s_pendingFilenameField = filenameField;
    s_pendingSourceHolder = sourceHolder;
    s_pendingSourceProperty = sourceProperty.toUtf8();
    qprompt_wasmPickFile("image/png, image/jpeg, image/gif, image/webp", kTargetText);
}

void WasmIntegration::pickPointerQml(QObject *filenameField, QObject *sourceHolder, const QString &sourceProperty)
{
    if (!filenameField || !sourceHolder || sourceProperty.isEmpty())
        return;
    s_pendingFilenameField = filenameField;
    s_pendingSourceHolder = sourceHolder;
    s_pendingSourceProperty = sourceProperty.toUtf8();
    qprompt_wasmPickFile(".qml,.QML", kTargetText);
}
