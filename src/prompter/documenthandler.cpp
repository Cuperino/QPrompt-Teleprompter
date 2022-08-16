/****************************************************************************
 **
 ** QPrompt
 ** Copyright (C) 2020-2022 Javier O. Cordero Pérez
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
#if defined(Q_OS_ANDROID)
#include <QtAndroid>
#include <QAndroidJniObject>
#endif
#if defined(Q_OS_ANDROID) || defined(Q_OS_IOS) || defined(Q_OS_WASM) || defined(Q_OS_WATCHOS) || defined(Q_OS_QNX)
#include <QGuiApplication>
#else
#include <QApplication>
#endif
#include <QFile>
#include <QFileInfo>
#include <QFileSelector>
#include <QFileSystemWatcher>
#include <QMimeDatabase>
#include <QQmlFile>
#include <QQmlFileSelector>
#include <QQuickTextDocument>
#include <QTextCharFormat>
#if QT_VERSION >= QT_VERSION_CHECK(6, 0, 0)
#include <QStringConverter>
#else
#include <QTextCodec>
#endif
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
    _fileSystemWatcher = new QFileSystemWatcher();
    pdf_importer = QString::fromStdString("TextExtraction");
    office_importer = QString::fromStdString("soffice");
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
        m_document->textDocument()->setDefaultStyleSheet(QString::fromStdString("body{margin:0;padding:0;color:\"#FFFFFF\";}a:link,a:visited,a:hover,a:active,a:before,a:after{text-decoration:overline;color:\"#FFFFFF\";background-color:rgba(0,0,0,0.0);}blockquote,address,cite,code,pre,h1,h2,h3,h4,h5,h6,table,tbody,td,th,thead,tr,dl,dt,big,small,tt,font{white-space:pre-wrap;font-size:medium;line-height:100%;margin:0;padding:0;border-width:2px;border-collapse:collapse;border-style:solid;border-color:\"#404040\";background-color:rgba(0,0,0,0.0);font-weight:normal;}table,tbody,thead{width:100%;}table,tbody,thead,td,th,tr{border:1pt;valign:top;background-color:rgba(0,0,0,0.0);}img{margin:5pt;width:50vw;}h1,h2,h3,h4,h5,h6,big{font-size:medium;font-weight:normal;}"));
        connect(m_document->textDocument(), &QTextDocument::modificationChanged, this, &DocumentHandler::modifiedChanged);
        connect(m_document->textDocument(), &QTextDocument::contentsChanged, this, &DocumentHandler::setMarkersListDirty);
    }
    Q_EMIT documentChanged();
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
    Q_EMIT cursorPositionChanged();
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
    Q_EMIT selectionStartChanged();
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
    Q_EMIT selectionEndChanged();
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
    format.setFontFamilies(QStringList(family));
    mergeFormatOnWordOrSelection(format);
    Q_EMIT fontFamilyChanged();
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
    Q_EMIT textColorChanged();
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
    Q_EMIT textBackgroundChanged();
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
    Q_EMIT alignmentChanged();
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
//     Q_EMIT anchorChanged();
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
    Q_EMIT boldChanged();
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
    Q_EMIT italicChanged();
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
    Q_EMIT underlineChanged();
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
    Q_EMIT strikeChanged();
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

void DocumentHandler::setKeyMarker(QString keyCodeString=QString::fromStdString(""))
{
    if (!keyCodeString.length())
        return;
    QTextCharFormat format;
    //qDebug() << keyCodeString;
    // Dev: in future versions, append, don't replace prior non-key values.
    format.setAnchorNames( {QString::fromStdString("key_") + keyCodeString} );
    format.setAnchor("#");
    format.setFontUnderline(true);
    format.setFontOverline(true);
    mergeFormatOnWordOrSelection(format);
    this->setMarkersListDirty();
    Q_EMIT markerChanged();
}

QString DocumentHandler::getMarkerKey()
{
    QString key = QString::fromStdString("");
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
    format.setFontOverline(marker);
    if (marker)
        format.setAnchorHref(QString::fromStdString("#"));
    else
        format.clearProperty(QTextFormat::AnchorHref);
    mergeFormatOnWordOrSelection(format);
    this->setMarkersListDirty();
    Q_EMIT markerChanged();
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
    Q_EMIT fontSizeChanged();
}

QString DocumentHandler::fileName() const
{
    const QString filePath = QQmlFile::urlToLocalFileOrQrc(m_fileUrl);
    const QString fileName = QFileInfo(filePath).fileName();
    if (fileName.isEmpty())
        return QStringLiteral("untitled.html");
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

void DocumentHandler::reload(const QString &fileUrl) {
    qWarning() << "reloading";
    load(QUrl(QString::fromStdString("file://") + fileUrl));
}

void DocumentHandler::load(const QUrl &fileUrl)
{
//     if (fileUrl == m_fileUrl)
//         return;
    
    QQmlEngine *engine = qmlEngine(this);
    if (!engine) {
        qWarning() << "load() called before DocumentHandler has QQmlEngine";
        return;
    }

    const QUrl path = QQmlFileSelector(engine).selector()->select(fileUrl);
    const QString fileName = QQmlFile::urlToLocalFileOrQrc(path);

    if (QFile::exists(fileName)) {
        QMimeType mime = QMimeDatabase().mimeTypeForFile(fileName);
        QFile file(fileName);
        if (file.open(QFile::ReadOnly)) {
            QByteArray data = file.readAll();
            if (QTextDocument *doc = textDocument()) {
                doc->setBaseUrl(path.adjusted(QUrl::RemoveFilename));
                // File formats managed by Qt
                if (mime.inherits(QString::fromStdString("text/html"))) {
                    QString html = QString::fromUtf8(data).replace(QRegularExpression(QString::fromStdString("((font-size|letter-spacing|word-spacing|font-weight):\\s*-?[\\d]+(?:.[\\d]+)*(?:(?:px)|(?:pt)|(?:em)|(?:ex));?\\s*)")), QString::fromStdString(""));
                    Q_EMIT loaded(html, Qt::RichText);
                }
                #if QT_VERSION >= 0x050F00
                else if (mime.inherits(QString::fromStdString("text/markdown")))
                    Q_EMIT loaded(QString::fromUtf8(data), Qt::MarkdownText);
                #endif
                // File formats imported using external software
                else {
                    ImportFormat type = NONE;
                    if (mime.inherits(QString::fromStdString("application/pdf")))
                        type = PDF;
                    else if (mime.inherits(QString::fromStdString("application/vnd.oasis.opendocument.text")))
                        type = ODT;
                    else if (mime.inherits(QString::fromStdString("application/vnd.openxmlformats-officedocument.wordprocessingml.document")))
                        type = DOCX;
                    else if (mime.inherits(QString::fromStdString("application/msword")))
                        type = DOC;
                    else if (mime.inherits(QString::fromStdString("application/rtf")))
                        type = RTF;
                    else if (mime.inherits(QString::fromStdString("application/x-abiword")))
                        type = ABW;
                    else if (mime.inherits(QString::fromStdString("application/epub+zip")))
                        type = EPUB;
                    else if (mime.inherits(QString::fromStdString("application/x-mobipocket-ebook")))
                        type = MOBI;
                    else if (mime.inherits(QString::fromStdString("application/vnd.amazon.ebook")))
                        type = AZW;
                    else if (mime.inherits(QString::fromStdString("application/x-iwork-pages-sffpages")))
                        type = PAGESX;
                    else if (mime.inherits(QString::fromStdString("application/vnd.apple.pages")))
                        type = PAGES;
                    // Dev: If type is incompatible and system isn't iOS, iPadOS, tvOS, watchOS, VxWorks, or the Universal Windows Platform
                    if (type != NONE) {
                        QString html = import(fileName, type);
                        // Process as HTML, even if it is plain text such that it gets rid of unnecessary whitespace.
                        Q_EMIT loaded(html, Qt::RichText);
                    }
                    // Read as raw or text file
                    else {
                        // Interpret RAW data using Qt's auto detection
#if QT_VERSION >= QT_VERSION_CHECK(6, 0, 0)
                        // I doubt that this is a proper conversion. Needs proper testing.
                        Q_EMIT loaded(QString::fromStdString(data.toStdString()), Qt::AutoText);
#else
                        QTextCodec *codec = QTextCodec::codecForName("UTF-8");
                        Q_EMIT loaded(codec->toUnicode(data), Qt::AutoText);
#endif
                    }
                }
                doc->setModified(false);
            }
            reset();
        }
        bool newPath=false;
        if (path!=this->fileUrl())
            newPath=true;
        if (path.isLocalFile() && (_fileSystemWatcher==nullptr || newPath)) {
            if (newPath)
                _fileSystemWatcher->removePath(QQmlFile::urlToLocalFileOrQrc(this->fileUrl()));
            _fileSystemWatcher->addPath(fileName);
            connect( _fileSystemWatcher, SIGNAL( fileChanged(QString) ), this, SLOT( reload(QString) ) );
        }
    }

    m_fileUrl = fileUrl;
    Q_EMIT fileUrlChanged();
}

QString DocumentHandler::import(QString fileName, ImportFormat type)
{
    QString program = QString::fromStdString("");
    QStringList arguments;

    // Preferring TextExtraction over alternatives for its better support for RTL languages.
    if (type==PDF) {
        program = pdf_importer;
        arguments << fileName;
    }
    // Using LibreOffice for most formats because of its ability to preserve formatting while converting to HTML.
    else if (type==ODT || type==DOCX || type==DOC || type==RTF || type==ABW || type==PAGESX || type==PAGES) {
        program = office_importer;
        arguments << QString::fromStdString("--headless") << QString::fromStdString("--cat") << QString::fromStdString("--convert-to") << QString::fromStdString("html:HTML") << fileName;
    }
    else if (type==EPUB || type==MOBI || type==AZW) {
        // Dev: not implemented
    }

    if (program==QString::fromStdString(""))
        return QString::fromStdString("Unsupported file format");

    // Begin execution of external filter
    QProcess convert(this);
    convert.start(program, arguments);

    if (!convert.waitForFinished())
        return QString::fromStdString("An error occurred while attempting to import. Make sure %1 is installed on your system and linked to.").arg(program);

    QByteArray html = convert.readAll();
    // if (type==DOCX || type==DOC || type==RTF || type==ABW || type==EPUB || type==MOBI || type==AZW)
    //     return filterHtml(html, true);
    return filterHtml(QString::fromStdString(html.toStdString()), false);
}

void DocumentHandler::saveAs(const QUrl &fileUrl)
{
    QTextDocument *doc = textDocument();
    if (!doc)
        return;
#if defined(Q_OS_ANDROID)
    // https://developer.android.com/reference/android/Manifest.permission
    const QStringList permissions = QStringList("android.permission.WRITE_EXTERNAL_STORAGE");
    const int milisecondTimeoutWait = 120000;
    QtAndroid::PermissionResultMap result = QtAndroid::requestPermissionsSync(permissions, milisecondTimeoutWait);
#endif
    const QString filePath = fileUrl.toLocalFile();
    const bool isHtml = QFileInfo(filePath).suffix().contains(QLatin1String("html"));
    QFile file(filePath);
    if (!file.open(QFile::WriteOnly | QFile::Truncate | (isHtml ? QFile::NotOpen : QFile::Text))) {
        Q_EMIT error(tr("Cannot save: ") + file.errorString());
        return;
    }
    file.write((isHtml ? doc->toHtml() : doc->toPlainText()).toUtf8());
    file.close();
    
    doc->setModified(false);
    
    if (fileUrl == m_fileUrl)
        return;
    
    m_fileUrl = fileUrl;
    Q_EMIT fileUrlChanged();
}

void DocumentHandler::save()
{
    const QString fileName = QQmlFile::urlToLocalFileOrQrc(m_fileUrl);
    QUrl url;
    url.setUrl(QString::fromStdString(QUrl::toPercentEncoding(fileName, "/:").toStdString()));
    saveAs(url);
}

void DocumentHandler::reset()
{
    Q_EMIT fontFamilyChanged();
    Q_EMIT alignmentChanged();
    Q_EMIT boldChanged();
    Q_EMIT italicChanged();
    Q_EMIT underlineChanged();
    Q_EMIT strikeChanged();
    Q_EMIT markerChanged();
    Q_EMIT fontSizeChanged();
    Q_EMIT textColorChanged();
    Q_EMIT textBackgroundChanged();
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
    if (html.contains(QRegularExpression(QString::fromStdString("(<meta\\s?\\s*name=\"?[gG]enerator\"?\\s?\\s*content=\"(?:(?:(?:(?:Libre)|(?:Open))Office)|(?:Microsoft)))"), QRegularExpression::CaseInsensitiveOption)) || html.contains(QRegularExpression(QString::fromStdString("<!DOCTYPE html PUBLIC \"-//ABISOURCE//DTD XHTML plus AWML")))) {
        comesFromRecognizedNativeSource = true;
        ignoreBlackTextColor = false;
    }
    // Check for Google Docs
    // Clean RegEx  id="docs-internal-guid-
    else if (html.contains(QString::fromStdString("id=\"docs-internal-guid-")))
        ignoreBlackTextColor = true;
    // No detection available for the online version of MS Office, because it contents bring no identifying signature.
    // Calligra isn't here either because it currently copies straight to text, preserving no formatting.

    // Proceed to Filter

    // Filters that run always:
    // 1. Remove HTML's non-scaling font-size attributes
    // Clean RegEx  (font-size:\s*[\d]+(?:.[\d]+)*(?:(?:px)|(?:pt)|(?:em)|(?:ex));?\s*)
    html = html.replace(QRegularExpression(QString::fromStdString("(font-size:\\s*[\\d]+(?:.[\\d]+)*(?:(?:px)|(?:pt)|(?:em)|(?:ex));?\\s*)")), QString::fromStdString(""));

    // Filters that apply only to native sources:
    if (comesFromRecognizedNativeSource)
        // 2. Remove text color attributes from body and CSS portion.  Running it 3 times ensures text, link, and vlink attributes are removed, irregardless of their order, while keeping regex maintainable
        // Clean RegEx  (?:(?:p\s*{.*(\scolor:\s*#[0123456789abcdefABCDEF]{3}(?:[0123456789abcdefABCDEF]{3})?;))|(?:(?:<[bB][oO][dD][yY]\s).*(\s(?:(?:text)|(?:v?link))="#[0123456789abcdefABCDEF]{3}(?:[0123456789abcdefABCDEF]{3})?").*(\s(?:(?:text)|(?:v?link))="#[0123456789abcdefABCDEF]{3}(?:[0123456789abcdefABCDEF]{3})?").*(\s(?:(?:text)|(?:v?link))="#[0123456789abcdefABCDEF]{3}(?:[0123456789abcdefABCDEF]{3})?")))
        html = html.replace(QRegularExpression(QString::fromStdString("(?:(?:p\\s*{.*(\\scolor:\\s*#[0123456789abcdefABCDEF]{3}(?:[0123456789abcdefABCDEF]{3})?;))|(?:(?:<[bB][oO][dD][yY]\\s).*(\\s(?:(?:text)|(?:v?link))=\"#[0123456789abcdefABCDEF]{3}(?:[0123456789abcdefABCDEF]{3})?\").*(\\s(?:(?:text)|(?:v?link))=\"#[0123456789abcdefABCDEF]{3}(?:[0123456789abcdefABCDEF]{3})?\").*(\\s(?:(?:text)|(?:v?link))=\"#[0123456789abcdefABCDEF]{3}(?:[0123456789abcdefABCDEF]{3})?\")))")), QString::fromStdString(""));
    // for (int i=0; i<3; ++i)
    //     html = html.replace(QRegularExpression("(?:(?:<[bB][oO][dD][yY]\\s).*(\\s(?:(?:text)|(?:v?link))=\"#[0123456789abcdefABCDEF]{3}(?:[0123456789abcdefABCDEF]{3})?\"))"), "");

    // Filters that apply only to non-native sources:
    else // if (!comesFromRecognizedNativeSource)
        // 3. Preserve highlights: Remove background color attributes from all elements except span, which is commonly used for highlights
        // Clean RegEx  (?:<[^sS][^pP][^aA][^nN](?:\s*[^>]*(\s*background(?:-color)?:\s*(?:(?:rgba?\(\d\d?\d?,\s*\d\d?\d?,\s*\d\d?\d?(?:,\s*[01]?(?:[.]\d\d*)?)?\))|(?:#[0-9a-fA-F]{3}(?:[0-9a-fA-F]{3})?));?)\s*[^>]*)*>)
        html = html.replace(QRegularExpression(QString::fromStdString("(?:<[^sS][^pP][^aA][^nN](?:\\s*[^>]*(\\s*background(?:-color)?:\\s*(?:(?:rgba?\\(\\d\\d?\\d?,\\s*\\d\\d?\\d?,\\s*\\d\\d?\\d?(?:,\\s*[01]?(?:[.]\\d\\d*)?)?\\))|(?:#[0-9a-fA-F]{3}(?:[0-9a-fA-F]{3})?));?)\\s*[^>]*)*>)")), QString::fromStdString(""));

    // Manual toggle filters
    if (ignoreBlackTextColor || !comesFromRecognizedNativeSource)
        // 4. Removal of black colored text attribute, subject to source editor.  Applies to Google Docs, OnlyOffice, Microsoft 365 Office Online and random websites.  Not used in LibreOffice, OpenOffice, WPS Office nor regular MS Office. 8-bit color values bellow 100 are ignored when rgb format is used. Has no effect on LibreOffice because of XML differences; nevertheless, there's no need to ignore dark text colors on LibreOffice because LibreOffice has a correct implementation of default colors.
        // Clean RegEx  (\s*(?:mso-style-textfill-fill-)?color:\s*(?:(?:rgba?\(\d{1,2},\s*\d{1,2},\s*\d{1,2}(?:,\s*[10]?(?:[.]00*)?)?\))|(?:black)|(?:windowtext)|(?:#0{3}(?:0{3})?));?)
        html = html.replace(QRegularExpression(QString::fromStdString("(\\s*(?:mso-style-textfill-fill-)?color:\\s*(?:(?:rgba?\\(\\d{1,2},\\s*\\d{1,2},\\s*\\d{1,2}(?:,\\s*[10]?(?:[.]00*)?)?\\))|(?:black)|(?:windowtext)|(?:#0{3}(?:0{3})?));?)")), QString::fromStdString(""));

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
    return Q_EMIT this->_markersModel->keySearch(key, cursorPosition(), false, true);
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

    Q_EMIT this->_markersModel->clearMarkers();

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
                    marker.length = currentFragment.length();
                    marker.url = currentFragment.charFormat().anchorHref();
                    // Go through anchor names for metadata to extract using const_iterator for best performance.
                    QStringList anchorNames = currentFragment.charFormat().anchorNames();
                    QStringList::const_iterator constIterator;
                    for (constIterator = anchorNames.constBegin(); constIterator != anchorNames.constEnd(); ++constIterator) {
                        QString anchorName = QString::fromStdString((*constIterator).toLocal8Bit().constData());
                        // Assign input key
                        if (anchorName.startsWith(QString::fromStdString("key_"))) {
                            marker.key = QStringView(anchorName).mid(4).toInt();
                            QKeySequence seq = QKeySequence(marker.key);
                            marker.keyLetter = seq.toString();
                        }
                        // Assign request type
                        else if (anchorName.startsWith(QString::fromStdString("req_")))
                            // If invalid, default to 0 (GET)
                            marker.requestType = QStringView(anchorName).mid(4).toInt(); // GET request by default  // Dev: Cast to enumerator to improve readability
//                         qDebug() << anchorName;
                    }
                    Q_EMIT this->_markersModel->appendMarker(marker);
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
    return Q_EMIT this->_markersModel->nextMarker(position);
}

Marker DocumentHandler::previousMarker(int position) {
//     if (this->_markersModel->rowCount()==0)
    if (markersListDirty())
        parse();
    return Q_EMIT this->_markersModel->previousMarker(position);
}

void DocumentHandler::preventSleep(bool prevent) {
#if defined(Q_OS_ANDROID)
    // The following code is commented out because, even tho it's technically correct, it makes QPrompt to crash on user interaction and during automatic state switching, depending on which flag is set.
//     // Use Android Java wrapper to set flag that prevents screen from turning off.
// 
//     // Native type list and locations:
//     // public interface WindowManager
//     // public static class WindowManager.LayoutParams
//     // public abstract class Window // android.view.Window
// 
//     // Code to wrap:
//     // import android.view.WindowManager;
//     // getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
//     // getWindow().clearFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
// 
//     qDebug() << "Attempt to prevent sleep.";
//     // Get pointer object to main/current Android activity.
//     QAndroidJniObject activity = QAndroidJniObject::callStaticObjectMethod("org/qtproject/qt5/android/QtNative", "activity", "()Landroid/app/Activity;");
//     if (activity.isValid()) {
//         // Get window pointer object from activity.
//         QAndroidJniObject window = activity.callObjectMethod("getWindow", "()Landroid/view/Window;");
//         if (window.isValid()) {
//             // Get flags to be toggled
//             const jint dimFlag = QAndroidJniObject::getStaticField<jint>("org/qtproject/qt5/android/view/WindowManager/LayoutParams", "FLAG_DIM_BEHIND"), // 2
//                        //blurFlag = QAndroidJniObject::getStaticField<jint>("org/qtproject/qt5/android/view/WindowManager/LayoutParams", "FLAG_BLUR_BEHIND"), // 4
//                        screenFlag = QAndroidJniObject::getStaticField<jint>("org/qtproject/qt5/android/view/WindowManager/LayoutParams", "FLAG_KEEP_SCREEN_ON"); // 128
//             if (prevent) {
//                 // Set the flag by passing integer argument to void addFlags method.
//                 window.callMethod<void>("addFlags", "(II)V", dimFlag, screenFLag);
//                 qDebug() << "Added window flags.";
//             }
//             else {
//                 // Unset the flags.
//                 window.callMethod<void>("clearFlags", "(II)V", dimFlag, screenFlag);
//                 qDebug() << "Removed window flags.";
//             }
//         }
//         else
//             qDebug() << "Window is not valid.";
//     }
//     else
//         qDebug() << "Activity is not valid.";
//     qDebug() << "End: Attempt to prevent sleep";
#elif defined(Q_OS_IOS)
    // To be implemented...
#endif
}
