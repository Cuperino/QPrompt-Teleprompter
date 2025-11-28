/****************************************************************************
 **
 ** QPrompt
 ** Copyright (C) 2020-2025 Javier O. Cordero Pérez
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
 ** You should have received a copy off the GNU General Public License
 ** along with this program.  If not, see <http://www.gnu.org/licenses/>.
 **
 ****************************************************************************/

/****************************************************************************
 **
 ** Copyright (C) 2017 The Qt Company Ltd.
 ** Contact: https://www.qt.io/licensing/
 **
 ** This file, for the most part, consists of code from examples of the Qt Toolkit.
 **
 ** $QT_BEGIN_LICENSE:BSD$
 ** Commercial License Usage
 ** Licensees holding valid commercial Qt licenses may use this file in
 ** accordance with the commercial license agreement provided with the
 ** Software or, alternatively, in accordance with the terms contained in
 ** a written agreement between you and The Qt Company. For licensing terms
 ** and conditions see https://www.qt.io/terms-conditions. For further
 ** information use the contact form at https://www.qt.io/contact-us.
 **
 ** BSD License Usage
 ** Alternatively, you may use the original examples code in this file under
 ** the terms of the BSD license as follows:
 **
 ** "Redistribution and use in source and binary forms, with or without
 ** modification, are permitted provided that the following conditions are
 ** met:
 **   * Redistributions of source code must retain the above copyright
 **     notice, this list of conditions and the following disclaimer.
 **   * Redistributions in binary form must reproduce the above copyright
 **     notice, this list of conditions and the following disclaimer in
 **     the documentation and/or other materials provided with the
 **     distribution.
 **   * Neither the name of The Qt Company Ltd nor the names of its
 **     contributors may be used to endorse or promote products derived
 **     from this software without specific prior written permission.
 **
 **
 ** THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 ** "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 ** LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 ** A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 ** OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 ** SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 ** LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 ** DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 ** THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 ** (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 ** OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE."
 **
 ** $QT_END_LICENSE$
 **
 ****************************************************************************/

#pragma once

#include <QFileSystemWatcher>
#include <QNetworkAccessManager>
#include <QObject>
#include <QQmlEngine>
#include <QTemporaryFile>
#include <QUrl>

#include "markersmodel.h"
#if !(defined(Q_OS_ANDROID) || defined(Q_OS_IOS) || defined(Q_OS_WASM) || defined(Q_OS_WATCHOS))
#include "systemfontchooserdialog.h"
#endif
#include <QFont>
#include <QQuickTextDocument>
#include <QTextCursor>
#include <QTextDocument>

QT_BEGIN_NAMESPACE

class DocumentHandler : public QObject
{
    Q_OBJECT
    QML_ELEMENT

    Q_PROPERTY(QQuickTextDocument *document READ document WRITE setDocument NOTIFY documentChanged)
    Q_PROPERTY(int cursorPosition READ cursorPosition WRITE setCursorPosition NOTIFY cursorPositionChanged)
    Q_PROPERTY(int selectionStart READ selectionStart WRITE setSelectionStart NOTIFY selectionStartChanged)
    Q_PROPERTY(int selectionEnd READ selectionEnd WRITE setSelectionEnd NOTIFY selectionEndChanged)

    Q_PROPERTY(QColor textColor READ textColor WRITE setTextColor NOTIFY textColorChanged)
    Q_PROPERTY(QColor textBackground READ textBackground WRITE setTextBackground NOTIFY textBackgroundChanged)
    Q_PROPERTY(QString fontFamily READ fontFamily WRITE setFontFamily NOTIFY fontFamilyChanged)
    Q_PROPERTY(Qt::Alignment alignment READ alignment WRITE setAlignment NOTIFY alignmentChanged)

    Q_PROPERTY(bool bold READ bold WRITE setBold NOTIFY boldChanged)
    Q_PROPERTY(bool italic READ italic WRITE setItalic NOTIFY italicChanged)
    Q_PROPERTY(bool underline READ underline WRITE setUnderline NOTIFY underlineChanged)
    Q_PROPERTY(bool strike READ strike WRITE setStrike NOTIFY strikeChanged)
    Q_PROPERTY(bool subscript READ subscript WRITE setSubscript NOTIFY verticalAlignmentChanged)
    Q_PROPERTY(bool superscript READ superscript WRITE setSuperscript NOTIFY verticalAlignmentChanged)
    Q_PROPERTY(bool autoReload READ autoReload WRITE setAutoReload NOTIFY autoReloadChanged)
    Q_PROPERTY(bool comesFromNetwork READ documentComesFromNetwork NOTIFY documentComesFromNetworkChanged)

    Q_PROPERTY(bool regularMarker READ regularMarker WRITE setMarker NOTIFY markerChanged)
    Q_PROPERTY(bool namedMarker READ namedMarker NOTIFY markerChanged)

    Q_PROPERTY(int fontSize READ fontSize WRITE setFontSize NOTIFY fontSizeChanged)

    Q_PROPERTY(QString fileName READ fileName NOTIFY fileUrlChanged)
    Q_PROPERTY(QString fileType READ fileType NOTIFY fileUrlChanged)
    Q_PROPERTY(QUrl fileUrl READ fileUrl NOTIFY fileUrlChanged)

    Q_PROPERTY(bool modified READ modified WRITE setModified NOTIFY modifiedChanged)

    //     Q_PROPERTY(MarkersModel* markers READ markers CONSTANT STORED false)

public:
    explicit DocumentHandler(QObject *parent = nullptr);
    ~DocumentHandler();

    QQuickTextDocument *document() const;
    void setDocument(QQuickTextDocument *document);

    int cursorPosition() const;
    void setCursorPosition(int position);

    int selectionStart() const;
    void setSelectionStart(int position);

    int selectionEnd() const;
    void setSelectionEnd(int position);

    QString fontFamily() const;
    void setFontFamily(const QString &family);

    QColor textColor() const;
    Q_INVOKABLE void setTextColor(const QColor &color);

    QColor textBackground() const;
    Q_INVOKABLE void setTextBackground(const QColor &color);

    Qt::Alignment alignment() const;
    void setAlignment(Qt::Alignment alignment);

    bool bold() const;
    void setBold(bool bold);

    bool italic() const;
    void setItalic(bool italic);

    bool underline() const;
    void setUnderline(bool underline);

    bool strike() const;
    void setStrike(bool strike);

    bool subscript() const;
    void setSubscript(bool subscript);

    bool superscript() const;
    void setSuperscript(bool superscript);

    bool autoReload() const;
    void setAutoReload(bool enable);

    bool documentComesFromNetwork() const;
    void setDocumentComesFromNetwork(bool comesFromNetwork);

    int fontSize() const;
    void setFontSize(int size);

    QString fileName() const;
    QString fileType() const;
    QUrl fileUrl() const;

    bool modified() const;
    void setModified(bool m);

    bool regularMarker() const;
    bool namedMarker() const;
    bool markersListDirty() const;
    void setMarker(bool marker);
    Q_INVOKABLE void setKeyMarker(QString keyCode);
    Q_INVOKABLE QString getMarkerKey();

    //     MarkersModel *markers() const;
    Q_INVOKABLE MarkersModel *markers() const;
    Q_INVOKABLE Marker previousMarker(quint64 position);
    Q_INVOKABLE Marker nextMarker(quint64 position);
    Q_INVOKABLE void setLineHeight(int lineHeight);
    Q_INVOKABLE void setParagraphHeight(int paragraphHeight);

    Q_INVOKABLE void paste(bool withoutFormating);
    Q_INVOKABLE void paste();
    Q_INVOKABLE QPoint replaceSelected(QString text);
    Q_INVOKABLE long replaceAll(const QString &searchedText, const QString &replacementText, bool regEx);
    Q_INVOKABLE void parse();
    Q_INVOKABLE QString filterHtml(QString html, bool ignoreBlackTextColor);

    // Search
    Q_INVOKABLE QPoint search(const QString &subString, const bool next = false, const bool reverse = false, const bool regEx = false, bool loop = true);
    Q_INVOKABLE int keySearch(int key);

    Q_INVOKABLE bool preventSleep(bool prevent);

#if !(defined(Q_OS_ANDROID) || defined(Q_OS_IOS) || defined(Q_OS_WASM) || defined(Q_OS_WATCHOS))
    Q_INVOKABLE bool showFontDialog();
#endif

    Q_INVOKABLE void loadFromNetwork(const QUrl &url);

public Q_SLOTS:
    void loadFromNetworkFinihed();
    void load(const QUrl &fileUrl);
    void reload(const QString &fileUrl);
    void saveAs(const QUrl &fileUrl);
    void save();
    void setMarkersListClean();
    void setMarkersListDirty();

Q_SIGNALS:
    void aboutToReload();
    void documentChanged();
    void cursorPositionChanged();
    void selectionStartChanged();
    void selectionEndChanged();

    void fontFamilyChanged(QString);
    void textColorChanged();
    void textBackgroundChanged();
    void alignmentChanged();

    void boldChanged();
    void italicChanged();
    void underlineChanged();
    void strikeChanged();
    void verticalAlignmentChanged();
    void autoReloadChanged();
    void documentComesFromNetworkChanged();

    void markerChanged();

    void fontSizeChanged();

    void textChanged();
    void fileUrlChanged();

    void loaded(Qt::TextFormat format);
    void error(const QString &message);

    void modifiedChanged();

private:
    void reset();
    QTextCursor textCursor() const;
    QTextDocument *textDocument() const;
    void unblockFileWatcher();
    void mergeFormatOnWordOrSelection(const QTextCharFormat &format);

    enum ImportFormat { NONE, PDF, ODT, DOCX, DOC, RTF, ABW, EPUB, MOBI, AZW, PAGES, PAGESX };
    void updateContents(const QString &text, Qt::TextFormat format);
#if !(defined(Q_OS_ANDROID) || defined(Q_OS_IOS) || defined(Q_OS_WASM) || defined(Q_OS_WATCHOS))
    QString import(const QString &fileName, ImportFormat);
#endif

    QQuickTextDocument *m_document;

    bool m_autoReload;
    bool m_reloading;
    bool m_documentComesFromNetwork;
    int m_cursorPosition;
    int m_selectionStart;
    int m_selectionEnd;

    MarkersModel *_markersModel;
    QFileSystemWatcher *_fileSystemWatcher;

#if !(defined(Q_OS_ANDROID) || defined(Q_OS_IOS) || defined(Q_OS_WASM) || defined(Q_OS_WATCHOS))
    SystemFontChooserDialog *m_fontDialog;
#endif
    QFont m_font;
    QUrl m_fileUrl;
    QString pdf_importer;
    QNetworkAccessManager *m_network;
    QNetworkReply *m_reply;
    QTemporaryFile *m_cache;
};
QT_END_NAMESPACE
