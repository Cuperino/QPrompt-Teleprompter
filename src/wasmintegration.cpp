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

#include <QPointer>
#include <QString>
#include <QVariant>
#include <emscripten.h>

namespace {
QPointer<QObject> s_pendingBackground;
}

extern "C" {
EMSCRIPTEN_KEEPALIVE
void qprompt_wasmImageReceived(const char *dataUrl)
{
    QPointer<QObject> background = s_pendingBackground;
    s_pendingBackground.clear();
    if (!background || !dataUrl || !*dataUrl)
        return;
    QMetaObject::invokeMethod(background.data(),
                              "setBackgroundImage",
                              Q_ARG(QVariant, QVariant::fromValue(QString::fromUtf8(dataUrl))));
}
}

EM_JS(void, qprompt_wasmPickImage, (), {
    var input = document.createElement('input');
    input.type = 'file';
    input.accept = 'image/png, image/jpeg, image/gif';
    input.style.display = 'none';
    input.addEventListener('change', function(event) {
        var file = event.target.files && event.target.files[0];
        document.body.removeChild(input);
        if (!file)
            return;
        var reader = new FileReader();
        reader.onload = function() {
            var dataUrl = reader.result;
            var bytes = (new TextEncoder()).encode(dataUrl);
            var ptr = _malloc(bytes.length + 1);
            HEAPU8.set(bytes, ptr);
            HEAPU8[ptr + bytes.length] = 0;
            _qprompt_wasmImageReceived(ptr);
            _free(ptr);
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
    qprompt_wasmPickImage();
}
