/****************************************************************************
 **
 ** QPrompt
 ** Copyright (C) 2020-2021 Javier O. Cordero Pérez
 **
 ** This file is part of QPrompt.
 **
 ** This program is free software: you can redistribute it and/or modify
 ** it under the terms of the GNU General Public License as published by
 ** the Free Software Foundation, either version 3 of the License, or
 ** (at your option) any later version.
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

#include "documenthandler.h"

#include <vector>

#include <QFile>
#include <QFileInfo>
#include <QFileSelector>
#include <QMimeDatabase>
#include <QQmlFile>
#include <QQmlFileSelector>
#include <QQuickTextDocument>
#include <QTextCharFormat>
#include <QTextCodec>
#include <QTextDocument>
#include <QTextBlock>
#include <QDebug>

DocumentHandler::DocumentHandler(QObject *parent)
: QObject(parent)
, m_document(nullptr)
, m_cursorPosition(-1)
, m_selectionStart(0)
, m_selectionEnd(0)
{
}

QQuickTextDocument *DocumentHandler::document() const
{
    return m_document;
}

void DocumentHandler::setDocument(QQuickTextDocument *document)
{
    if (document == m_document)
        return;
    
    if (m_document)
        m_document->textDocument()->disconnect(this);
    m_document = document;
    if (m_document)
        connect(m_document->textDocument(), &QTextDocument::modificationChanged, this, &DocumentHandler::modifiedChanged);
    emit documentChanged();
}

int DocumentHandler::cursorPosition() const
{
    return m_cursorPosition;
}

void DocumentHandler::setCursorPosition(int position)
{
    if (position == m_cursorPosition)
        return;
    
    m_cursorPosition = position;
    reset();
    emit cursorPositionChanged();
}

int DocumentHandler::selectionStart() const
{
    return m_selectionStart;
}

void DocumentHandler::setSelectionStart(int position)
{
    if (position == m_selectionStart)
        return;
    
    m_selectionStart = position;
    emit selectionStartChanged();
}

int DocumentHandler::selectionEnd() const
{
    return m_selectionEnd;
}

void DocumentHandler::setSelectionEnd(int position)
{
    if (position == m_selectionEnd)
        return;
    
    m_selectionEnd = position;
    emit selectionEndChanged();
}

QString DocumentHandler::fontFamily() const
{
    QTextCursor cursor = textCursor();
    if (cursor.isNull())
        return QString();
    QTextCharFormat format = cursor.charFormat();
    return format.font().family();
}

void DocumentHandler::setFontFamily(const QString &family)
{
    QTextCharFormat format;
    format.setFontFamily(family);
    mergeFormatOnWordOrSelection(format);
    emit fontFamilyChanged();
}

QColor DocumentHandler::textColor() const
{
    QTextCursor cursor = textCursor();
    if (cursor.isNull())
        return QColor(Qt::white);
    QTextCharFormat format = cursor.charFormat();
    return format.foreground().color();
}

void DocumentHandler::setTextColor(const QColor &color)
{
    QTextCharFormat format;
    format.setForeground(QBrush(color));
    mergeFormatOnWordOrSelection(format);
    emit textColorChanged();
}

Qt::Alignment DocumentHandler::alignment() const
{
    QTextCursor cursor = textCursor();
    if (cursor.isNull())
        return Qt::AlignLeft;
    return textCursor().blockFormat().alignment();
}

void DocumentHandler::setAlignment(Qt::Alignment alignment)
{
    QTextBlockFormat format;
    format.setAlignment(alignment);
    QTextCursor cursor = textCursor();
    cursor.mergeBlockFormat(format);
    emit alignmentChanged();
}

// bool DocumentHandler::anchor() const
// {
//     QTextCursor cursor = textCursor();
//     if (cursor.isNull())
//         return false;
//     return textCursor().charFormat().fontWeight() == QFont::Bold;
// }
// 
// void DocumentHandler::setAnchor(QStringList names)
// {
//     QTextCharFormat format;
//     format.setAnchorNames(names);
//     mergeFormatOnWordOrSelection(format);
//     emit anchorChanged();
// }
// 
bool DocumentHandler::bold() const
{
    QTextCursor cursor = textCursor();
    if (cursor.isNull())
        return false;
    return textCursor().charFormat().fontWeight() == QFont::Bold;
}

void DocumentHandler::setBold(bool bold)
{
    QTextCharFormat format;
    format.setFontWeight(bold ? QFont::Bold : QFont::Normal);
    mergeFormatOnWordOrSelection(format);
    emit boldChanged();
}

bool DocumentHandler::italic() const
{
    QTextCursor cursor = textCursor();
    if (cursor.isNull())
        return false;
    return textCursor().charFormat().fontItalic();
}

void DocumentHandler::setItalic(bool italic)
{
    QTextCharFormat format;
    format.setFontItalic(italic);
    mergeFormatOnWordOrSelection(format);
    emit italicChanged();
}

bool DocumentHandler::underline() const
{
    QTextCursor cursor = textCursor();
    if (cursor.isNull())
        return false;
    return textCursor().charFormat().fontUnderline();
}

void DocumentHandler::setUnderline(bool underline)
{
    QTextCharFormat format;
    format.setFontUnderline(underline);
    mergeFormatOnWordOrSelection(format);
    emit underlineChanged();
}

bool DocumentHandler::strike() const
{
    QTextCursor cursor = textCursor();
    if (cursor.isNull())
        return false;
    return textCursor().charFormat().fontStrikeOut();
}

void DocumentHandler::setStrike(bool strike)
{
    QTextCharFormat format;
    format.setFontStrikeOut(strike);
    mergeFormatOnWordOrSelection(format);
    emit strikeChanged();
}

bool DocumentHandler::marker() const
{
    QTextCursor cursor = textCursor();
    if (cursor.isNull())
        return false;
    return textCursor().charFormat().isAnchor();
}

void DocumentHandler::setMarker(bool marker)
{
    QTextCharFormat format;
    qDebug() << marker;
    format.setAnchor(marker);
    format.setFontUnderline(marker);
    // Avoid dealing with color changes by using FontOverline to distinguish Marker from other properties.
    format.setFontOverline(marker);
    if (marker) {
        // Named markers could have two names attached to them...
        format.setAnchorNames(QStringList("marker"));
        //format.setForeground(QColor("lightblue"));
        // There's no need to set href, this would only conflict with actual links in the document.
        //format.setAnchorHref("#");
    }
    else {
        format.setAnchorNames(QStringList());
        //format.clearForeground();
        // There's no need to set href, this would only conflict with actual links in the document.
        //format.setAnchorHref("");
    }
    mergeFormatOnWordOrSelection(format);
    emit markerChanged();
}

int DocumentHandler::fontSize() const
{
    QTextCursor cursor = textCursor();
    if (cursor.isNull())
        return 0;
    QTextCharFormat format = cursor.charFormat();
    return format.font().pointSize();
}

void DocumentHandler::setFontSize(int size)
{
    if (size <= 0)
        return;
    
    QTextCursor cursor = textCursor();
    if (cursor.isNull())
        return;
    
    if (!cursor.hasSelection())
        cursor.select(QTextCursor::WordUnderCursor);
    
    if (cursor.charFormat().property(QTextFormat::FontPointSize).toInt() == size)
        return;
    
    QTextCharFormat format;
    format.setFontPointSize(size);
    mergeFormatOnWordOrSelection(format);
    emit fontSizeChanged();
}

QString DocumentHandler::fileName() const
{
    const QString filePath = QQmlFile::urlToLocalFileOrQrc(m_fileUrl);
    const QString fileName = QFileInfo(filePath).fileName();
    if (fileName.isEmpty())
        return QStringLiteral("untitled.txt");
    return fileName;
}

QString DocumentHandler::fileType() const
{
    return QFileInfo(fileName()).suffix();
}

QUrl DocumentHandler::fileUrl() const
{
    return m_fileUrl;
}

void DocumentHandler::load(const QUrl &fileUrl)
{
    if (fileUrl == m_fileUrl)
        return;
    
    QQmlEngine *engine = qmlEngine(this);
    if (!engine) {
        qWarning() << "load() called before DocumentHandler has QQmlEngine";
        return;
    }
    
    const QUrl path = QQmlFileSelector::get(engine)->selector()->select(fileUrl);
    const QString fileName = QQmlFile::urlToLocalFileOrQrc(path);
    if (QFile::exists(fileName)) {
        QMimeType mime = QMimeDatabase().mimeTypeForFile(fileName);
        QFile file(fileName);
        if (file.open(QFile::ReadOnly)) {
            QByteArray data = file.readAll();
            if (QTextDocument *doc = textDocument()) {
                doc->setBaseUrl(path.adjusted(QUrl::RemoveFilename));
                if (mime.inherits("text/markdown")) {
                    emit loaded(QString::fromUtf8(data), Qt::MarkdownText);
                } else {
                    QTextCodec *codec = QTextCodec::codecForName("UTF-8");
                    emit loaded(codec->toUnicode(data), Qt::AutoText);
                }
                doc->setModified(false);
            }
            
            reset();
        }
    }
    
    m_fileUrl = fileUrl;
    emit fileUrlChanged();
}

void DocumentHandler::saveAs(const QUrl &fileUrl)
{
    QTextDocument *doc = textDocument();
    if (!doc)
        return;
    
    const QString filePath = fileUrl.toLocalFile();
    const bool isHtml = QFileInfo(filePath).suffix().contains(QLatin1String("htm"));
    QFile file(filePath);
    if (!file.open(QFile::WriteOnly | QFile::Truncate | (isHtml ? QFile::NotOpen : QFile::Text))) {
        emit error(tr("Cannot save: ") + file.errorString());
        return;
    }
    file.write((isHtml ? doc->toHtml() : doc->toPlainText()).toUtf8());
    file.close();
    
    doc->setModified(false);
    
    if (fileUrl == m_fileUrl)
        return;
    
    m_fileUrl = fileUrl;
    emit fileUrlChanged();
}

void DocumentHandler::save()
{
    const QString fileName = QQmlFile::urlToLocalFileOrQrc(m_fileUrl);
    saveAs(fileName);
}

void DocumentHandler::reset()
{
    emit fontFamilyChanged();
    emit alignmentChanged();
    emit boldChanged();
    emit italicChanged();
    emit underlineChanged();
    emit strikeChanged();
    emit markerChanged();
    emit fontSizeChanged();
    emit textColorChanged();
}

QTextCursor DocumentHandler::textCursor() const
{
    QTextDocument *doc = textDocument();
    if (!doc)
        return QTextCursor();
    
    QTextCursor cursor = QTextCursor(doc);
    if (m_selectionStart != m_selectionEnd) {
        cursor.setPosition(m_selectionStart);
        cursor.setPosition(m_selectionEnd, QTextCursor::KeepAnchor);
    } else {
        cursor.setPosition(m_cursorPosition);
    }
    return cursor;
}

QTextDocument *DocumentHandler::textDocument() const
{
    if (!m_document)
        return nullptr;
    
    return m_document->textDocument();
}

void DocumentHandler::mergeFormatOnWordOrSelection(const QTextCharFormat &format)
{
    QTextCursor cursor = textCursor();
    if (!cursor.hasSelection())
        cursor.select(QTextCursor::WordUnderCursor);
    cursor.mergeCharFormat(format);
}

bool DocumentHandler::modified() const
{
    return m_document && m_document->textDocument()->isModified();
}

void DocumentHandler::setModified(bool m)
{
    if (m_document)
        m_document->textDocument()->setModified(m);
}

// Markers (Anchors)

void DocumentHandler::parse() {

    struct LINE {
        QRectF rect;
        QString text;
    };

    struct MARKER {
        int position;
        QStringList names;
        QString text;
    };

    size_t size = 1024;
    std::vector<LINE> lines;
    std::vector<MARKER> anchors;
    lines.reserve(size);
    anchors.reserve(size>>4);

    // Go through the document once
    for (QTextBlock it = this->textDocument()->begin(); it != this->textDocument()->end(); it = it.next()) {
        QTextBlock::iterator jt;

        // Navigate the document's physical layout and extract line dimensions and text. Dimensions would be used for telemetry, text would be used as a reference of what to expect during speech recognition.
        for (int i=0; i<it.layout()->lineCount(); i++) {
            LINE line;
            line.rect = it.layout()->lineAt(i).naturalTextRect();
            line.text = it.text().mid(it.layout()->lineAt(i).textStart(), it.layout()->lineAt(i).textLength());
            lines.push_back(line);
        }

        // Navigate the document's formatting and extract markers information.
        for (jt = it.begin(); !(jt.atEnd()); ++jt) {
            QTextFragment currentFragment = jt.fragment();
            if (currentFragment.isValid()) {
                // Additional fragment processing would be done here...
                // Extract marker information:
                if (currentFragment.charFormat().isAnchor()) {
                    MARKER marker;
                    marker.position = currentFragment.position();
                    marker.names = currentFragment.charFormat().anchorNames();
                    marker.text = currentFragment.text();
                    anchors.push_back(marker);
                }
            }
        }
    }

    #ifdef QT_DEBUG
    // Output results to terminal, only in debug compilation.
    qDebug() << "- Lines -";
    for (unsigned long i=0; i<lines.size(); i++)
        qDebug() << lines.at(i).rect << lines.at(i).text;

    qDebug() << "- Markers -";
    for (unsigned long i=0; i<anchors.size(); i++)
        qDebug() << anchors.at(i).position << anchors.at(i).text << anchors.at(i).names;
    #endif
}
