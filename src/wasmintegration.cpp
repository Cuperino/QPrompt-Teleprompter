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

#include <QCoreApplication>
#include <QByteArray>
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QHostAddress>
#include <QPointer>
#include <QString>
#include <QStringLiteral>
#include <QUrl>
#include <QVariant>
#include <emscripten.h>

namespace {
constexpr int kTargetBackground = 0;
constexpr int kTargetText = 1;

QPointer<QObject> s_pendingBackground;
QPointer<QObject> s_pendingFilenameField;
QPointer<QObject> s_pendingSourceHolder;
QByteArray s_pendingSourceProperty;
QPointer<QObject> s_pendingDocumentReceiver;
QPointer<QObject> s_pendingSaveReceiver;

bool isPrivateNetworkHost(const QString &host)
{
    QStringView view(host);
    if (view.startsWith(QLatin1Char('[')) && view.endsWith(QLatin1Char(']')))
        view = view.mid(1, view.size() - 2);
    const qsizetype zone = view.indexOf(QLatin1Char('%'));
    if (zone >= 0)
        view = view.left(zone);

    const QHostAddress addr(view.toString());
    if (addr.isNull())
        return false;

    return addr.isLoopback()
        || addr.isLinkLocal()
        || addr.isPrivateUse()
        || addr.isInSubnet(QHostAddress(QStringLiteral("100.64.0.0")), 10);
}
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

// Qt's WASM file dialog hands back "weblocalfile:" URLs whose reads block on a
// JS promise, which aborts on the main thread unless Asyncify or JSPI is
// enabled. Instead, read the picked file in JS, then copy it into MEMFS,
// where QFile reads synchronously, and let QML load it like any local file.
EMSCRIPTEN_KEEPALIVE
void qprompt_wasmDocumentReceived(const char *filename, const unsigned char *data, int size)
{
    QPointer<QObject> receiver = s_pendingDocumentReceiver;
    s_pendingDocumentReceiver.clear();
    if (!receiver || !filename || !*filename || size < 0)
        return;

    const QString dirPath = QDir::tempPath() + QStringLiteral("/qprompt-documents");
    if (!QDir().mkpath(dirPath))
        return;
    // Strip any path components the browser may report.
    const QString name = QFileInfo(QString::fromUtf8(filename)).fileName();
    const QString path = dirPath + QLatin1Char('/') + name;
    QFile file(path);
    if (!file.open(QIODevice::WriteOnly | QIODevice::Truncate))
        return;
    file.write(reinterpret_cast<const char *>(data), size);
    file.close();

    QMetaObject::invokeMethod(receiver.data(),
                              "loadPickedDocument",
                              Q_ARG(QVariant, QVariant::fromValue(QUrl::fromLocalFile(path))));
}

EMSCRIPTEN_KEEPALIVE
void qprompt_wasmDocumentSaved(int accepted)
{
    QPointer<QObject> receiver = s_pendingSaveReceiver;
    s_pendingSaveReceiver.clear();
    if (!receiver)
        return;
    QMetaObject::invokeMethod(receiver.data(),
                              "wasmSaveFinished",
                              Q_ARG(QVariant, QVariant::fromValue(accepted != 0)));
}
}

// Saves through the File System Access API where available (Chromium), which
// lets the user pick the destination and reports cancellation. Elsewhere,
// fall back to a download, which can't report whether the user kept the file.
EM_JS(void, qprompt_wasmSaveDocument, (const char *contentCStr, const char *nameCStr), {
    var content = UTF8ToString(contentCStr);
    var name = UTF8ToString(nameCStr);
    var blob = new Blob([content], { type: 'text/html' });
    var download = function() {
        var url = URL.createObjectURL(blob);
        var a = document.createElement('a');
        a.href = url;
        a.download = name;
        a.style.display = 'none';
        document.body.appendChild(a);
        a.click();
        document.body.removeChild(a);
        setTimeout(function() { URL.revokeObjectURL(url); }, 0);
        _qprompt_wasmDocumentSaved(1);
    };
    if (typeof window.showSaveFilePicker !== 'function') {
        download();
        return;
    }
    window.showSaveFilePicker({
        suggestedName: name,
        types: [{ description: 'HTML', accept: { 'text/html': ['.html', '.htm'] } }]
    }).then(function(handle) {
        return handle.createWritable().then(function(writable) {
            return writable.write(blob).then(function() { return writable.close(); });
        });
    }).then(function() {
        _qprompt_wasmDocumentSaved(1);
    }, function(err) {
        if (err && err.name === 'AbortError')
            _qprompt_wasmDocumentSaved(0);
        else
            download();
    });
});

EM_JS(void, qprompt_wasmPickDocument, (const char *acceptCStr), {
    var input = document.createElement('input');
    input.type = 'file';
    input.accept = UTF8ToString(acceptCStr);
    input.style.display = 'none';
    input.addEventListener('change', function(event) {
        var file = event.target.files && event.target.files[0];
        document.body.removeChild(input);
        if (!file)
            return;
        file.arrayBuffer().then(function(buffer) {
            var bytes = new Uint8Array(buffer);
            var name = file.name || 'document';
            var nameLen = lengthBytesUTF8(name) + 1;
            var namePtr = _malloc(nameLen);
            stringToUTF8(name, namePtr, nameLen);
            var dataPtr = _malloc(Math.max(bytes.length, 1));
            HEAPU8.set(bytes, dataPtr);
            _qprompt_wasmDocumentReceived(namePtr, dataPtr, bytes.length);
            _free(namePtr);
            _free(dataPtr);
        });
    });
    document.body.appendChild(input);
    input.click();
});

EM_JS(void, qprompt_wasmToggleFullscreen, (), {
    var fsElement = document.fullscreenElement
        || document.webkitFullscreenElement
        || document.mozFullScreenElement
        || document.msFullscreenElement;
    if (fsElement) {
        if (document.exitFullscreen)
            document.exitFullscreen();
        else if (document.webkitExitFullscreen)
            document.webkitExitFullscreen();
        else if (document.mozCancelFullScreen)
            document.mozCancelFullScreen();
        else if (document.msExitFullscreen)
            document.msExitFullscreen();
    } else {
        var target = document.documentElement;
        if (target.requestFullscreen)
            target.requestFullscreen();
        else if (target.webkitRequestFullscreen)
            target.webkitRequestFullscreen();
        else if (target.mozRequestFullScreen)
            target.mozRequestFullScreen();
        else if (target.msRequestFullscreen)
            target.msRequestFullscreen();
    }
});

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

void WasmIntegration::pickDocument(QObject *receiver)
{
    if (!receiver)
        return;
    s_pendingDocumentReceiver = receiver;
    qprompt_wasmPickDocument(".html,.htm,.xhtml,.md,.markdown,.txt,.text,text/html,text/markdown,text/plain");
}

void WasmIntegration::saveDocument(QObject *receiver, const QString &html, const QString &suggestedName)
{
    s_pendingSaveReceiver = receiver;
    qprompt_wasmSaveDocument(html.toUtf8().constData(), suggestedName.toUtf8().constData());
}

void WasmIntegration::toggleBrowserFullscreen()
{
    qprompt_wasmToggleFullscreen();
}

void WasmIntegration::setPageTitle(const QString &title)
{
    EM_ASM({ document.title = UTF8ToString($0); }, title.toUtf8().constData());
}

void WasmIntegration::officialHost() const
{
    const QString h = hostname();
    if (!(h.endsWith("localhost") || h.endsWith("qprompt.app") || isPrivateNetworkHost(h)))
        QCoreApplication::quit();
}

QString WasmIntegration::hostname() const
{
    char *raw = reinterpret_cast<char *>(EM_ASM_PTR({
        var host = (window.location && window.location.hostname) || '';
        var len = lengthBytesUTF8(host) + 1;
        var ptr = _malloc(len);
        stringToUTF8(host, ptr, len);
        return ptr;
    }));
    QString result = QString::fromUtf8(raw);
    free(raw);
    return result;
}
