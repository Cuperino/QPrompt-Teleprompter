/****************************************************************************
 **
 ** QPrompt
 ** Copyright (C) 2020-2021 Javier O. Cordero Pérez
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

#if defined(Q_OS_ANDROID) || defined(Q_OS_IOS) || defined(Q_OS_WASM) || defined(Q_OS_WATCHOS) || defined(Q_OS_QNX)
#include <QGuiApplication>
#else
#include <QApplication>
#endif
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
#include <QClipboard>
#include <QMimeData>
#include <QRegularExpression>
#include <QProcess>
#include <QDebug>
#include <QKeySequence>

DocumentHandler::DocumentHandler(QObject *parent)
: QObject(parent)
, m_document(nullptr)
, m_cursorPosition(-1)
, m_selectionStart(0)
, m_selectionEnd(0)
, _markersModel(nullptr)

{
    _markersModel = new MarkersModel();
    pdf_importer = QString("TextExtraction");
    office_importer = QString("soffice");
}

QQuickTextDocument *DocumentHandler::document() const
{
    return m_document;
}

// QAbstractListModel *DocumentHandler::markers() const
MarkersModel *DocumentHandler::markers() const
{
//     QAbstractListModel *model = _markersModel;
//     return model ;
    return _markersModel;
}

void DocumentHandler::setDocument(QQuickTextDocument *document)
{
    if (document == m_document)
        return;
    
    if (m_document)
        m_document->textDocument()->disconnect(this);
    m_document = document;
    if (m_document) {
        m_document->textDocument()->setDefaultStyleSheet("body{margin:0;padding:0;color:\"#FFFFFF\";}a:link,a:visited,a:hover,a:active,a:before,a:after{text-decoration:overline;color:\"#FFFFFF\";background-color:rgba(0,0,0,0.0);}p,html,body,div,span,blockquote,address,cite,code,pre,h1,h2,h3,h4,h5,h6,li,ol,ul,table,tbody,td,th,thead,tr,dl,dt,big,small,tt,font{white-space:pre-wrap;font-size:medium;text-align:center;line-height:100%;margin:0;padding:0;border-width:2px;border-collapse:collapse;border-style:solid;border-color:\"#404040\";background-color:rgba(0,0,0,0.0);font-weight:normal;}table,tbody,thead{width:100%;}table,tbody,thead,td,th,tr{border:1pt;align:center;valign:top;background-color:rgba(0,0,0,0.0);}img{margin:5pt;width:50vw;}h1,h2,h3,h4,h5,h6,big{font-size:medium;font-weight:normal;}");
        connect(m_document->textDocument(), &QTextDocument::modificationChanged, this, &DocumentHandler::modifiedChanged);
        connect(m_document->textDocument(), &QTextDocument::contentsChanged, this, &DocumentHandler::setMarkersListDirty);
    }
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

QColor DocumentHandler::textBackground() const
{
    QTextCursor cursor = textCursor();
    if (cursor.isNull())
        return QColor(Qt::transparent);
    QTextCharFormat format = cursor.charFormat();
    return format.background().color();
}

void DocumentHandler::setTextBackground(const QColor &color)
{
    QTextCharFormat format;
    format.setBackground(QBrush(color));
    mergeFormatOnWordOrSelection(format);
    emit textBackgroundChanged();
}

Qt::Alignment DocumentHandler::alignment() const
{
    QTextCursor cursor = textCursor();
    if (cursor.isNull())
        return Qt::AlignCenter;
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

bool DocumentHandler::regularMarker() const
{
    QTextCursor cursor = textCursor();
    if (cursor.isNull())
        return false;
    return textCursor().charFormat().isAnchor() && textCursor().charFormat().anchorNames().size()==0;
}

bool DocumentHandler::namedMarker() const
{
    QTextCursor cursor = textCursor();
    if (cursor.isNull())
        return false;
    return textCursor().charFormat().isAnchor() && textCursor().charFormat().anchorNames().size()>0;
}

void DocumentHandler::setKeyMarker(QString keyCodeString="")
{
    if (!keyCodeString.length())
        return;
    QTextCharFormat format;
    //qDebug() << keyCodeString;
    // Dev: in future versions, append, don't replace prior non-key values.
    format.setAnchorNames( {"key_" + keyCodeString} );
    format.setAnchor("#");
    format.setFontUnderline(true);
    format.setFontOverline(true);
    mergeFormatOnWordOrSelection(format);
    this->setMarkersListDirty();
    emit markerChanged();
}

QString DocumentHandler::getMarkerKey()
{
    QString key = "";
    QTextCursor cursor = textCursor();
    if (cursor.isNull())
        return key;
    // Get anchor keyCode
    QStringList names = cursor.charFormat().anchorNames();
    // Convert keyCode to user readable key
    if (!names.isEmpty()) {
        QString keyCodeString = names.first().mid(4);
        QKeySequence seq = QKeySequence(keyCodeString.toInt());
        key = seq.toString();
    }
    else
        qDebug() << "Empty";
    // Return key string
    return key;
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
        format.setAnchorNames(QStringList());
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
    this->setMarkersListDirty();
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
                // File formats managed by Qt
                if (mime.inherits("text/html"))
                    emit loaded(QString::fromUtf8(data), Qt::RichText);
                #if QT_VERSION >= 0x050F00
                else if (mime.inherits("text/markdown"))
                    emit loaded(QString::fromUtf8(data), Qt::MarkdownText);
                #endif
                // File formats imported using external software
                else {
                    ImportFormat type = NONE;
                    if (mime.inherits("application/pdf"))
                        type = PDF;
                    else if (mime.inherits("application/vnd.oasis.opendocument.text"))
                        type = ODT;
                    else if (mime.inherits("application/vnd.openxmlformats-officedocument.wordprocessingml.document"))
                        type = DOCX;
                    else if (mime.inherits("application/msword"))
                        type = DOC;
                    else if (mime.inherits("application/rtf"))
                        type = RTF;
                    else if (mime.inherits("application/x-abiword"))
                        type = ABW;
                    else if (mime.inherits("application/epub+zip"))
                        type = EPUB;
                    else if (mime.inherits("application/x-mobipocket-ebook"))
                        type = MOBI;
                    else if (mime.inherits("application/vnd.amazon.ebook"))
                        type = AZW;
                    else if (mime.inherits("application/x-iwork-pages-sffpages"))
                        type = PAGESX;
                    else if (mime.inherits("application/vnd.apple.pages"))
                        type = PAGES;
                    // Dev: If type is incompatible and system isn't iOS, iPadOS, tvOS, watchOS, VxWorks, or the Universal Windows Platform
                    if (type != NONE) {
                        QString html = import(fileName, type);
                        // Process as HTML, even if it is plain text such that it gets rid of unnecessary whitespace.
                        emit loaded(html, Qt::RichText);
                    }
                    // Read as raw or text file
                    else {
                        // Interpret RAW data using Qt's auto detection
                        QTextCodec *codec = QTextCodec::codecForName("UTF-8");
                        emit loaded(codec->toUnicode(data), Qt::AutoText);
                    }
                }
                doc->setModified(false);
            }
            reset();
        }
    }

    m_fileUrl = fileUrl;
    emit fileUrlChanged();
}

QString DocumentHandler::import(QString fileName, ImportFormat type)
{
    QString program = "";
    QStringList arguments;

    // Preferring TextExtraction over alternatives for its better support for RTL languages.
    if (type==PDF) {
        program = pdf_importer;
        arguments << fileName;
    }
    // Using LibreOffice for most formats because of its ability to preserve formatting while converting to HTML.
    else if (type==ODT || type==DOCX || type==DOC || type==RTF || type==ABW || type==PAGESX || type==PAGES) {
        program = office_importer;
        arguments << "--headless" << "--cat" << "--convert-to" << "html:HTML" << fileName;
    }
    else if (type==EPUB || type==MOBI || type==AZW) {
        // Dev: not implemented
    }

    if (program=="")
        return "Unsupported file format";

    // Begin execution of external filter
    QProcess convert(this);
    convert.start(program, arguments);

    if (!convert.waitForFinished())
        return QString("An error occurred while attempting to import. Make sure %1 is installed on your system and linked to.").arg(program);

    QByteArray html = convert.readAll();
    // if (type==DOCX || type==DOC || type==RTF || type==ABW || type==EPUB || type==MOBI || type==AZW)
    //     return filterHtml(html, true);
    return filterHtml(html, false);
}

void DocumentHandler::saveAs(const QUrl &fileUrl)
{
    QTextDocument *doc = textDocument();
    if (!doc)
        return;
    
    const QString filePath = fileUrl.toLocalFile();
    const bool isHtml = QFileInfo(filePath).suffix().contains(QLatin1String("html"));
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
    emit textBackgroundChanged();
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

QString DocumentHandler::filterHtml(QString html, bool ignoreBlackTextColor=true)
// ignoreBlackTextColor=true is the default because websites tend to force black text color
{
    // Auto-detect content origin
    bool comesFromRecognizedNativeSource = false;
    // Check for native sources, such as LibreOffice, MS Office, WPS Office, and AbiWord
    // Clean RegEx  (<meta\s?\s*name="?[gG]enerator"?\s?\s*content="(?:(?:(?:(?:Libre)|(?:Open))Office)|(?:Microsoft)))
    // Clean RegEx  <!DOCTYPE html PUBLIC "-//ABISOURCE//DTD XHTML plus AWML
    if (html.contains(QRegularExpression("(<meta\\s?\\s*name=\"?[gG]enerator\"?\\s?\\s*content=\"(?:(?:(?:(?:Libre)|(?:Open))Office)|(?:Microsoft)))", QRegularExpression::CaseInsensitiveOption)) || html.contains(QRegularExpression("<!DOCTYPE html PUBLIC \"-//ABISOURCE//DTD XHTML plus AWML"))) {
        comesFromRecognizedNativeSource = true;
        ignoreBlackTextColor = false;
    }
    // Check for Google Docs
    // Clean RegEx  id="docs-internal-guid-
    else if (html.contains("id=\"docs-internal-guid-"))
        ignoreBlackTextColor = true;
    // No detection available for the online version of MS Office, because it contents bring no identifying signature.
    // Calligra isn't here either because it currently copies straight to text, preserving no formatting.

    // Proceed to Filter

    // Filters that run always:
    // 1. Remove HTML's non-scaling font-size attributes
    // Clean RegEx  (font-size:\s*[\d]+(?:.[\d]+)*(?:(?:px)|(?:pt)|(?:em)|(?:ex));?\s*)
    html = html.replace(QRegularExpression("(font-size:\\s*[\\d]+(?:.[\\d]+)*(?:(?:px)|(?:pt)|(?:em)|(?:ex));?\\s*)"), "");

    // Filters that apply only to native sources:
    if (comesFromRecognizedNativeSource)
        // 2. Remove text color attributes from body and CSS portion.  Running it 3 times ensures text, link, and vlink attributes are removed, irregardless of their order, while keeping regex maintainable
        // Clean RegEx  (?:(?:p\s*{.*(\scolor:\s*#[0123456789abcdefABCDEF]{3}(?:[0123456789abcdefABCDEF]{3})?;))|(?:(?:<[bB][oO][dD][yY]\s).*(\s(?:(?:text)|(?:v?link))="#[0123456789abcdefABCDEF]{3}(?:[0123456789abcdefABCDEF]{3})?").*(\s(?:(?:text)|(?:v?link))="#[0123456789abcdefABCDEF]{3}(?:[0123456789abcdefABCDEF]{3})?").*(\s(?:(?:text)|(?:v?link))="#[0123456789abcdefABCDEF]{3}(?:[0123456789abcdefABCDEF]{3})?")))
        html = html.replace(QRegularExpression("(?:(?:p\\s*{.*(\\scolor:\\s*#[0123456789abcdefABCDEF]{3}(?:[0123456789abcdefABCDEF]{3})?;))|(?:(?:<[bB][oO][dD][yY]\\s).*(\\s(?:(?:text)|(?:v?link))=\"#[0123456789abcdefABCDEF]{3}(?:[0123456789abcdefABCDEF]{3})?\").*(\\s(?:(?:text)|(?:v?link))=\"#[0123456789abcdefABCDEF]{3}(?:[0123456789abcdefABCDEF]{3})?\").*(\\s(?:(?:text)|(?:v?link))=\"#[0123456789abcdefABCDEF]{3}(?:[0123456789abcdefABCDEF]{3})?\")))"), "");
    // for (int i=0; i<3; ++i)
    //     html = html.replace(QRegularExpression("(?:(?:<[bB][oO][dD][yY]\\s).*(\\s(?:(?:text)|(?:v?link))=\"#[0123456789abcdefABCDEF]{3}(?:[0123456789abcdefABCDEF]{3})?\"))"), "");

    // Filters that apply only to non-native sources:
    else // if (!comesFromRecognizedNativeSource)
        // 3. Preserve highlights: Remove background color attributes from all elements except span, which is commonly used for highlights
        // Clean RegEx  (?:<[^sS][^pP][^aA][^nN](?:\s*[^>]*(\s*background(?:-color)?:\s*(?:(?:rgba?\(\d\d?\d?,\s*\d\d?\d?,\s*\d\d?\d?(?:,\s*[01]?(?:[.]\d\d*)?)?\))|(?:#[0-9a-fA-F]{3}(?:[0-9a-fA-F]{3})?));?)\s*[^>]*)*>)
        html = html.replace(QRegularExpression("(?:<[^sS][^pP][^aA][^nN](?:\\s*[^>]*(\\s*background(?:-color)?:\\s*(?:(?:rgba?\\(\\d\\d?\\d?,\\s*\\d\\d?\\d?,\\s*\\d\\d?\\d?(?:,\\s*[01]?(?:[.]\\d\\d*)?)?\\))|(?:#[0-9a-fA-F]{3}(?:[0-9a-fA-F]{3})?));?)\\s*[^>]*)*>)"), "");

    // Manual toggle filters
    if (ignoreBlackTextColor || !comesFromRecognizedNativeSource)
        // 4. Removal of black colored text attribute, subject to source editor.  Applies to Google Docs, OnlyOffice, Microsoft 365 Office Online and random websites.  Not used in LibreOffice, OpenOffice, WPS Office nor regular MS Office. 8-bit color values bellow 100 are ignored when rgb format is used. Has no effect on LibreOffice because of XML differences; nevertheless, there's no need to ignore dark text colors on LibreOffice because LibreOffice has a correct implementation of default colors.
        // Clean RegEx  (\s*(?:mso-style-textfill-fill-)?color:\s*(?:(?:rgba?\(\d{1,2},\s*\d{1,2},\s*\d{1,2}(?:,\s*[10]?(?:[.]00*)?)?\))|(?:black)|(?:windowtext)|(?:#0{3}(?:0{3})?));?)
        html = html.replace(QRegularExpression("(\\s*(?:mso-style-textfill-fill-)?color:\\s*(?:(?:rgba?\\(\\d{1,2},\\s*\\d{1,2},\\s*\\d{1,2}(?:,\\s*[10]?(?:[.]00*)?)?\\))|(?:black)|(?:windowtext)|(?:#0{3}(?:0{3})?));?)"), "");

    // Filtering complete
    // qDebug() << html;
    return html;
}

void DocumentHandler::paste(bool withoutFormating=false)
{
    // qDebug() << "Managed Paste";
#if defined(Q_OS_ANDROID) || defined(Q_OS_IOS) || defined(Q_OS_WASM) || defined(Q_OS_WATCHOS) || defined(Q_OS_QNX)
    const QClipboard *clipboard = QGuiApplication::clipboard();
#else
    const QClipboard *clipboard = QApplication::clipboard();
#endif
    const QMimeData *mimeData = clipboard->mimeData();

    if (mimeData->hasHtml()) {
        if (withoutFormating)
            this->textCursor().insertText(mimeData->text());
        else {
            QString filteredHtml = this->filterHtml(mimeData->html());
            this->textCursor().insertHtml(filteredHtml);
        }
    }
    else if (mimeData->hasText())
        this->textCursor().insertText(mimeData->text());
    // Moved image test to last because having it first breaks pasting from AbiWord
    else if (mimeData->hasImage()) {
        // Dev: Add image support
        // setPixmap(qvariant_cast<QPixmap>(mimeData->imageData()));
    }
}

void DocumentHandler::paste()
{
    paste(false);
}

bool DocumentHandler::markersListDirty() const
{
    return _markersModel->dirty;
}

void DocumentHandler::setMarkersListClean()
{
    _markersModel->dirty = false;
}

void DocumentHandler::setMarkersListDirty()
{
    _markersModel->dirty = true;
}

// Search
QPoint DocumentHandler::search(const QString &subString, const bool next, const bool reverse) {
    // qDebug() << "pre" << this->cursorPosition() << this->selectionStart() << this->selectionEnd();
    QTextCursor cursor;
    if (reverse)
        cursor = this->textDocument()->find(subString, this->selectionStart(), QTextDocument::FindBackward);
    else if (next)
        cursor = this->textDocument()->find(subString, this->selectionEnd());
    else
        cursor = this->textDocument()->find(subString, this->selectionStart());
    // If no more results, go to the corresponding start position and do the search once more
    if (cursor.selectionStart()==-1 && cursor.selectionStart()==-1 && cursor.selectionEnd()==-1) {
        if (reverse)
            cursor = this->textDocument()->find(subString, textDocument()->characterCount(), QTextDocument::FindBackward);
        else
            cursor = this->textDocument()->find(subString, 0);
    }
    // Update cursor
    if (cursor.selectionStart()!=-1) {
        this->setCursorPosition(cursor.selectionStart());
        this->setSelectionStart(cursor.selectionStart());
    }
    this->setSelectionEnd(cursor.selectionEnd());
    // qDebug() << "post" << this->cursorPosition() << this->selectionStart() << this->selectionEnd() << Qt::endl;
    // Return selection range so that it can be passed to the editor
    return QPoint(this->selectionStart(), this->selectionEnd());
}

int DocumentHandler::keySearch(int key) {
    return this->_markersModel->keySearch(key, cursorPosition(), false, true);
}

// Line Height
void DocumentHandler::setLineHeight(int lineHeight)
{
    QTextCursor cursor = textCursor();
    if (cursor.isNull())
        return;
    cursor.joinPreviousEditBlock();
    cursor.select(QTextCursor::Document);
    QTextBlockFormat modifier = QTextBlockFormat();
    modifier.setLineHeight(lineHeight, QTextBlockFormat::ProportionalHeight);
    cursor.mergeBlockFormat(modifier);
    cursor.endEditBlock();
}

// Markers (Anchors)

void DocumentHandler::parse() {

    struct LINE {
        QRectF rect;
        QString text;
    };

    size_t size = 1024;
    std::vector<LINE> lines;
    lines.reserve(size);

    this->_markersModel->clearMarkers();

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

        // Navigate the document's formatting and extract markers' information.
        for (jt = it.begin(); !(jt.atEnd()); ++jt) {
            QTextFragment currentFragment = jt.fragment();
            if (currentFragment.isValid()) {
                // Additional fragment processing would be done here...
                // Extract marker information:
                if (currentFragment.charFormat().isAnchor()) {
                    Marker marker;
                    marker.text = currentFragment.text();
                    marker.position = currentFragment.position();
                    marker.url = currentFragment.charFormat().anchorHref();
                    // Go through anchor names for metadata to extract using const_iterator for best performance.
                    QStringList anchorNames = currentFragment.charFormat().anchorNames();
                    QStringList::const_iterator constIterator;
                    for (constIterator = anchorNames.constBegin(); constIterator != anchorNames.constEnd(); ++constIterator) {
                        QString anchorName = (*constIterator).toLocal8Bit().constData();
                        // Assign input key
                        if (anchorName.startsWith("key_"))
                            marker.key = anchorName.mid(4).toInt();
                        // Assign request type
                        else if (anchorName.startsWith("req_"))
                            // If invalid, default to 0 (GET)
                            marker.requestType = anchorName.mid(4).toInt(); // GET request by default  // Dev: Cast to enumerator to improve readability
//                         qDebug() << anchorName;
                    }
                    this->_markersModel->appendMarker(marker);
                }
            }
        }
    }
    // Set markers list as clean
    this->setMarkersListClean();

    #ifdef QT_DEBUG
    // Output results to terminal, only in debug compilation.
//     qDebug() << "- Lines (" << lines.size() << ") -";
//     for (unsigned long i=0; i<lines.size(); i++)
//         qDebug() << lines.at(i).rect << lines.at(i).text;

//     qDebug() << "- Markers (" << this->_markersModel->rowCount() << ") -";
    for (int i=0; i<this->_markersModel->rowCount(); i++) {
//         qDebug() << this->_markersModel.data(i, 0);
        // qDebug() << this->_markersModel.get(i).position << this->_markersModel.get(i).text << this->_markersModel.get(i).names;
        // qDebug() << anchors.at(i).position() << anchors.at(i).text() << anchors.at(i).charFormat().anchorNames();
        //qDebug() << i;
    }
    #endif
}

Marker DocumentHandler::nextMarker(int position) {
//     if (this->_markersModel->rowCount()==0)
    if (markersListDirty())
        parse();
    return this->_markersModel->nextMarker(position);
}

Marker DocumentHandler::previousMarker(int position) {
//     if (this->_markersModel->rowCount()==0)
    if (markersListDirty())
        parse();
    return this->_markersModel->previousMarker(position);
}
