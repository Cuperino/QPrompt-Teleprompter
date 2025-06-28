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
#include <QAndroidJniObject>
#include <QtAndroid>
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
#include <QSettings>
#include <QTextCharFormat>
#if QT_VERSION >= QT_VERSION_CHECK(6, 0, 0)
#include <QStringConverter>
#else
#include <QTextCodec>
#endif
#include <QClipboard>
#include <QDebug>
#include <QKeySequence>
#include <QMimeData>
#include <QNetworkReply>
#include <QProcess>
#include <QRegularExpression>
#include <QTemporaryFile>
#include <QTextBlock>
#include <QTextDocument>
#include <QTimer>

DocumentHandler::DocumentHandler(QObject *parent)
    : QObject(parent)
    , m_document(nullptr)
    , m_autoReload(true)
    , m_cursorPosition(-1)
    , m_selectionStart(0)
    , m_selectionEnd(0)
    , _markersModel(nullptr)

{
    _markersModel = new MarkersModel();
    _fileSystemWatcher = new QFileSystemWatcher();
    pdf_importer = QString::fromUtf8("TextExtraction");

    m_network = new QNetworkAccessManager(this);
    m_cache = new QTemporaryFile(this);
    connect(m_network, &QNetworkAccessManager::finished, this, &DocumentHandler::loadFromNetworkFinihed);

#if !(defined(Q_OS_ANDROID) || defined(Q_OS_IOS) || defined(Q_OS_WASM) || defined(Q_OS_WATCHOS))
    m_fontDialog = new SystemFontChooserDialog();
    connect(m_fontDialog, &SystemFontChooserDialog::fontFamilyChanged, this, &DocumentHandler::setFontFamily);
#endif
}

DocumentHandler::~DocumentHandler()
{
#if !(defined(Q_OS_ANDROID) || defined(Q_OS_IOS) || defined(Q_OS_WASM) || defined(Q_OS_WATCHOS))
    delete m_fontDialog;
#endif
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
        m_document->textDocument()->setDefaultStyleSheet(QString::fromUtf8(
            "body{margin:0;padding:0;color:\"#FFFFFF\";}a:link,a:visited,a:hover,a:active,a:before,a:after{text-decoration:overline;color:\"#FFFFFF\";"
            "background-color:rgba(0,0,0,0.0);}blockquote,address,cite,code,pre,h1,h2,h3,h4,h5,h6,table,tbody,td,th,thead,tr,dl,dt,tt{white-"
            "space:pre-wrap;line-height:100%;margin:0;padding:0;border-width:2px;border-collapse:collapse;border-style:solid;border-color:\"#"
            "404040\";background-color:rgba(0,0,0,0.0);font-weight:normal;}table,tbody,thead{width:100%;}table,tbody,thead,td,th,tr{border:1pt;valign:top;"
            "background-color:rgba(0,0,0,0.0);}img{margin:5pt;width:50vw;}p{margin:0;}h1,h2,h3,h4,h5,h6{font-size:medium;font-weight:normal;}"));
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
    const QFont font = format.font();
    return font.families().length() ? font.families().constFirst() : font.family();
}

void DocumentHandler::setFontFamily(const QString &family)
{
    QTextCharFormat format;
    format.setFontFamilies(QStringList(family));
    mergeFormatOnWordOrSelection(format);
    Q_EMIT fontFamilyChanged(family);
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

bool DocumentHandler::subscript() const
{
    QTextCursor cursor = textCursor();
    if (cursor.isNull())
        return false;
    return textCursor().charFormat().verticalAlignment() == QTextCharFormat::AlignSubScript;
}

void DocumentHandler::setSubscript(bool subscript)
{
    QTextCharFormat format;
    if (subscript)
        format.setVerticalAlignment(QTextCharFormat::AlignSubScript);
    else
        format.setVerticalAlignment(QTextCharFormat::AlignNormal);
    mergeFormatOnWordOrSelection(format);
    Q_EMIT verticalAlignmentChanged();
}

bool DocumentHandler::superscript() const
{
    QTextCursor cursor = textCursor();
    if (cursor.isNull())
        return false;
    return textCursor().charFormat().verticalAlignment() == QTextCharFormat::AlignSuperScript;
}

void DocumentHandler::setSuperscript(bool superscript)
{
    QTextCharFormat format;
    if (superscript)
        format.setVerticalAlignment(QTextCharFormat::AlignSuperScript);
    else {
        format.setVerticalAlignment(QTextCharFormat::AlignNormal);
        // format.setFontPointSize(12);
    }
    mergeFormatOnWordOrSelection(format);
    Q_EMIT verticalAlignmentChanged();
}

bool DocumentHandler::regularMarker() const
{
    QTextCursor cursor = textCursor();
    if (cursor.isNull())
        return false;
    return textCursor().charFormat().isAnchor() && textCursor().charFormat().anchorNames().size() == 0;
}

bool DocumentHandler::namedMarker() const
{
    QTextCursor cursor = textCursor();
    if (cursor.isNull())
        return false;
    return textCursor().charFormat().isAnchor() && textCursor().charFormat().anchorNames().size() > 0;
}

void DocumentHandler::setKeyMarker(QString keyCodeString = QString::fromUtf8(""))
{
    if (!keyCodeString.length())
        return;
    QTextCharFormat format;
    // qDebug() << keyCodeString;
    //  Dev: in future versions, append, don't replace prior non-key values.
    format.setAnchorNames({QString::fromUtf8("key_") + keyCodeString});
    format.setAnchor("#");
    format.setAnchor(true);
    format.setFontUnderline(true);
    format.setFontOverline(true);
    mergeFormatOnWordOrSelection(format);
    this->setMarkersListDirty();
    Q_EMIT markerChanged();
}

#if !(defined(Q_OS_ANDROID) || defined(Q_OS_IOS) || defined(Q_OS_WASM) || defined(Q_OS_WATCHOS))
bool DocumentHandler::showFontDialog()
{
    QTextCursor cursor = textCursor();
    if (!cursor.hasSelection())
        cursor.select(QTextCursor::WordUnderCursor);
    // Trim text and remove invisible character "￼", which represents images
    QString text = cursor.selectedText().trimmed().remove("￼");
    const int length = text.length();
    if (length == 0)
        return true;
    else if (length > 64) {
        text.truncate(64);
        int end = text.lastIndexOf(" ");
        text.truncate(end);
        text = tr("%1…").arg(text);
    }
    m_fontDialog->show(fontFamily(), text);
    return false;
}
#endif

QString DocumentHandler::getMarkerKey()
{
    QString key = QString::fromUtf8("");
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
    } else
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
        format.setAnchorHref(QString::fromUtf8("#"));
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

void DocumentHandler::reload(const QString &fileUrl)
{
    m_reloading = true;
    auto url = QUrl(QString::fromUtf8("file://") + fileUrl);
    if (url == m_fileUrl) {
        qWarning() << "reloading";
        load(url);
    }
}

void DocumentHandler::loadFromNetwork(const QUrl &url)
{
    QUrl resultingUrl;
    QNetworkRequest req;
    if (url.isRelative()) {
        resultingUrl.setScheme("http");
        resultingUrl.setHost(url.path());
        resultingUrl.setPort(url.port());
        resultingUrl.setUserName(url.userName());
        resultingUrl.setPassword(url.password());
        resultingUrl.setFragment(url.fragment());
        resultingUrl.setQuery(url.query());
    } else
        resultingUrl = url;
    if (url.isValid()) {
        req = QNetworkRequest(resultingUrl);
        req.setAttribute(QNetworkRequest::RedirectPolicyAttribute, true);
        m_reply = m_network->get(req);
    }
}

void DocumentHandler::loadFromNetworkFinihed()
{
    auto document = m_reply->readAll();

    if (document != "") {
        static QRegularExpression regex_0(
            QString::fromUtf8("((font-size|letter-spacing|word-spacing|font-weight):\\s*-?[\\d]+(?:.[\\d]+)*(?:(?:px)|(?:pt)|(?:em)|(?:ex));?\\s*)"));
        QString html = QString::fromUtf8(document).replace(regex_0, QString::fromUtf8(""));

        m_fileUrl = m_cache->fileName();
        Q_EMIT aboutToReload();
        updateContents(html, Qt::RichText);
        Q_EMIT fileUrlChanged();
    }
}

bool DocumentHandler::autoReload() const
{
    return m_autoReload;
}

void DocumentHandler::setAutoReload(bool enable)
{
    m_autoReload = enable;
}

void DocumentHandler::load(const QUrl &fileUrl)
{
    QQmlEngine *engine = qmlEngine(this);
    if (!engine) {
        qWarning() << "load() called before DocumentHandler has QQmlEngine";
        return;
    }

    bool skipAutoReload = false;
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
                if (mime.inherits(QString::fromUtf8("text/html"))) {
                    static QRegularExpression regex_0(QString::fromUtf8(
                        "((font-size|letter-spacing|word-spacing|font-weight):\\s*-?[\\d]+(?:.[\\d]+)*(?:(?:px)|(?:pt)|(?:em)|(?:ex));?\\s*)"));
                    QString html = QString::fromUtf8(data).replace(regex_0, QString::fromUtf8(""));
                    updateContents(html, Qt::RichText);
                }
#if QT_VERSION >= 0x050F00
                else if (mime.inherits(QString::fromUtf8("text/markdown")))
                    updateContents(QString::fromUtf8(data), Qt::MarkdownText);
#endif
                // File formats imported using external software
                else {
#if !(defined(Q_OS_ANDROID) || defined(Q_OS_IOS) || defined(Q_OS_WASM) || defined(Q_OS_WATCHOS))
                    ImportFormat type = NONE;
                    if (mime.inherits(QString::fromUtf8("application/pdf")))
                        type = PDF;
                    else if (mime.inherits(QString::fromUtf8("application/vnd.oasis.opendocument.text"))) {
                        type = ODT;
                        skipAutoReload = true;
                    } else if (mime.inherits(QString::fromUtf8("application/vnd.openxmlformats-officedocument.wordprocessingml.document"))) {
                        type = DOCX;
                        skipAutoReload = true;
                    } else if (mime.inherits(QString::fromUtf8("application/msword"))) {
                        type = DOC;
                        skipAutoReload = true;
                    } else if (mime.inherits(QString::fromUtf8("application/rtf"))) {
                        type = RTF;
                        skipAutoReload = true;
                    } else if (mime.inherits(QString::fromUtf8("application/x-abiword"))) {
                        type = ABW;
                        skipAutoReload = true;
                    } else if (mime.inherits(QString::fromUtf8("application/epub+zip")))
                        type = EPUB;
                    else if (mime.inherits(QString::fromUtf8("application/x-mobipocket-ebook")))
                        type = MOBI;
                    else if (mime.inherits(QString::fromUtf8("application/vnd.amazon.ebook")))
                        type = AZW;
                    else if (mime.inherits(QString::fromUtf8("application/x-iwork-pages-sffpages"))) {
                        type = PAGESX;
                        skipAutoReload = true;
                    } else if (mime.inherits(QString::fromUtf8("application/vnd.apple.pages"))) {
                        type = PAGES;
                        skipAutoReload = true;
                    }
                    // Dev: If type is incompatible and system isn't iOS, iPadOS, tvOS, watchOS, VxWorks, or the Universal Windows Platform
                    if (type != NONE) {
                        QString html = import(fileName, type);
                        // Process as HTML, even if it is plain text such that it gets rid of unnecessary whitespace.
                        updateContents(html, Qt::RichText);
                    }
                    // Read as raw or text file
                    else {
#endif
                        // Interpret RAW data using Qt's auto detection
#if QT_VERSION >= QT_VERSION_CHECK(6, 0, 0)
                        // I doubt that this is a proper conversion. Needs proper testing.
                        updateContents(QString::fromUtf8(data.toStdString()), Qt::AutoText);
#else
                        QTextCodec *codec = QTextCodec::codecForName("utf-8");
                        updateContents(codec->toUnicode(data));
#endif
#if !(defined(Q_OS_ANDROID) || defined(Q_OS_IOS) || defined(Q_OS_WASM) || defined(Q_OS_WATCHOS))
                    }
#endif
                }
                doc->setModified(false);
            }
            reset();
        }
        bool newPath = false;
        if (path != this->fileUrl())
            newPath = true;
        if (path.isLocalFile() && newPath && _fileSystemWatcher != nullptr) {
            _fileSystemWatcher->removePath(QQmlFile::urlToLocalFileOrQrc(this->fileUrl()));
            if (!skipAutoReload || autoReload()) {
                _fileSystemWatcher->addPath(fileName);
                connect(_fileSystemWatcher, &QFileSystemWatcher::fileChanged, this, &DocumentHandler::reload, Qt::UniqueConnection);
            }
        }
    }

    m_fileUrl = fileUrl;

    if (m_reloading)
        m_reloading = false;
    else
        document()->textDocument()->clearUndoRedoStacks();

    Q_EMIT fileUrlChanged();
}

#if !(defined(Q_OS_ANDROID) || defined(Q_OS_IOS) || defined(Q_OS_WASM) || defined(Q_OS_WATCHOS))
QString DocumentHandler::import(const QString &fileName, ImportFormat type)
{
    QString program = QString::fromUtf8("");
    QStringList arguments;

    //// Preferring TextExtraction over alternatives for its better support for RTL languages.
    // if (type == PDF) {
    //     program = pdf_importer;
    //     arguments << fileName;
    // }
    // else
    // Using LibreOffice for most formats because of its ability to preserve formatting while converting to HTML.
    if (type == ODT || type == DOCX || type == DOC || type == RTF || type == ABW || type == PAGESX || type == PAGES) {
#if (defined(Q_OS_MACOS))
        QSettings settings(QCoreApplication::organizationDomain(), QCoreApplication::applicationName());
#else
        QSettings settings(QCoreApplication::organizationName(), QCoreApplication::applicationName().toLower());
#endif
#if defined(Q_OS_WINDOWS)
        program = settings.value("paths/soffice", "C:/Program Files/LibreOffice/program/soffice.exe").toString();
        if (program == "")
            program = "C:/Program Files/LibreOffice/program/soffice.exe";
#elif defined(Q_OS_MACOS)
        program = settings.value("paths/soffice", "/Applications/LibreOffice.app").toString();
        if (program == "")
            program = "/Applications/LibreOffice.app";
        program += "/Contents/MacOS/soffice";
#else
        program = settings.value("paths/soffice", "soffice").toString();
        if (program == "")
            program = "soffice";
#endif
        arguments << QString::fromUtf8("--headless") << QString::fromUtf8("--cat") << QString::fromUtf8("--convert-to") << QString::fromUtf8("html:HTML")
                  << fileName;
    } else if (type == EPUB || type == MOBI || type == AZW) {
        // Dev: not implemented
    }

    if (program == QString::fromUtf8(""))
        return QString::fromUtf8("Unsupported file format");

    // Begin execution of external filter
    QProcess convert(this);
    convert.start(program, arguments);

    if (!convert.waitForFinished())
        return QString::fromUtf8(
                   "An error occurred while attempting to open file in a third party format. Go to \"Main Menu\", \"Other Setttings\", then \"External Tools\" "
                   "to make sure a corresponding import tool is properly configured.")
            .arg(program);

    const QByteArray bytes = convert.readAll();
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0) && defined(Q_OS_WINDOWS)
    const QTextCodec *codec = QTextCodec::codecForName("utf-8");
    const QString html = codec->toUnicode(bytes.data());
#else
    const QString html = QString::fromStdString(bytes.toStdString());
#endif
    // if (type==DOCX || type==DOC || type==RTF || type==ABW || type==EPUB || type==MOBI || type==AZW)
    //     return filterHtml(html, true);
    return filterHtml(html, false);
}
#endif

void DocumentHandler::updateContents(const QString &text, Qt::TextFormat format) {
    QTextCursor cursor = textCursor();
    cursor.select(QTextCursor::Document);
    cursor.removeSelectedText();
    switch(format) {
    case Qt::PlainText:
        cursor.insertText(text);
        break;
    case Qt::MarkdownText:
        cursor.insertMarkdown(text);
        break;
    case Qt::RichText:
        // Document metadata extraction would happen at this time
        Q_FALLTHROUGH();
    case Qt::AutoText:
        cursor.insertHtml(text);
        break;
    }
    Q_EMIT loaded(format);
}

void DocumentHandler::unblockFileWatcher()
{
    _fileSystemWatcher->blockSignals(false);
}

void DocumentHandler::saveAs(const QUrl &fileUrl)
{
    QTextDocument *doc = textDocument();
    if (!doc)
        return;
    _fileSystemWatcher->blockSignals(true);
#ifdef Q_OS_ANDROID
    // https://developer.android.com/reference/android/Manifest.permission
    const QStringList permissions = QStringList("android.permission.WRITE_EXTERNAL_STORAGE");
    const int milisecondTimeoutWait = 120000;
    QtAndroid::PermissionResultMap result = QtAndroid::requestPermissionsSync(permissions, milisecondTimeoutWait);
    QString filePath = fileUrl.toString();
    QFile file(filePath);
    const bool isHtml = true;
#else
    QString filePath = fileUrl.toLocalFile();
    QFile file(filePath);
    QFileInfo fileInfo = QFileInfo(filePath);
    const bool isHtml = fileInfo.suffix().contains(QLatin1String("html")) || fileInfo.suffix().contains(QLatin1String("htm"))
        || fileInfo.suffix().contains(QLatin1String("xhtml")) || fileInfo.suffix().contains(QLatin1String("HTML"))
        || fileInfo.suffix().contains(QLatin1String("HTM")) || fileInfo.suffix().contains(QLatin1String("XHTML"));
#endif

    if (!file.open(QFile::WriteOnly | QFile::Truncate | (isHtml ? QFile::NotOpen : QFile::Text))) {
        Q_EMIT error(tr("Cannot save: ") + file.errorString());
        return;
    }

    file.write((isHtml ? doc->toHtml() : doc->toPlainText()).toUtf8());
    file.flush();
    file.close();

    doc->setModified(false);

    QTimer::singleShot(2600, this, &DocumentHandler::unblockFileWatcher);

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
    Q_EMIT fontFamilyChanged(fontFamily());
    Q_EMIT alignmentChanged();
    Q_EMIT boldChanged();
    Q_EMIT italicChanged();
    Q_EMIT underlineChanged();
    Q_EMIT strikeChanged();
    Q_EMIT markerChanged();
    Q_EMIT fontSizeChanged();
    Q_EMIT textColorChanged();
    Q_EMIT textBackgroundChanged();
    Q_EMIT verticalAlignmentChanged();
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

QString DocumentHandler::filterHtml(QString html, bool ignoreBlackTextColor = true)
// ignoreBlackTextColor=true is the default because websites tend to force black text color
{
    // Auto-detect content origin
    bool comesFromRecognizedNativeSource = false;
    // Check for native sources, such as LibreOffice, MS Office, WPS Office, and AbiWord
    // Clean RegEx:  (<meta\s?\s*name="?[gG]enerator"?\s?\s*content="(?:(?:(?:(?:Libre)|(?:Open))Office)|(?:Microsoft)))
    static QRegularExpression regex_1(
        QString::fromUtf8("(<meta\\s?\\s*name=\"?[gG]enerator\"?\\s?\\s*content=\"(?:(?:(?:(?:Libre)|(?:Open))Office)|(?:Microsoft)))"),
        QRegularExpression::CaseInsensitiveOption);
    // Clean RegEx:  <!DOCTYPE html PUBLIC "-//ABISOURCE//DTD XHTML plus AWML
    static QRegularExpression regex_2(QString::fromUtf8("<!DOCTYPE html PUBLIC \"-//ABISOURCE//DTD XHTML plus AWML"));
    if (html.contains(regex_1) || html.contains(regex_2)) {
        comesFromRecognizedNativeSource = true;
        ignoreBlackTextColor = false;
    }
    // Check for Google Docs
    // Clean RegEx:  id="docs-internal-guid-
    else if (html.contains(QString::fromUtf8("id=\"docs-internal-guid-")))
        ignoreBlackTextColor = true;
    // No detection available for the online version of MS Office, because it contents bring no identifying signature.
    // Calligra isn't here either because it currently copies straight to text, preserving no formatting.

    // Proceed to Filter

    // Filters that run always:
    // 1. Remove HTML's non-scaling font-size attributes
    // Clean RegEx:  (font-size:\s*[\d]+(?:.[\d]+)*(?:(?:px)|(?:pt)|(?:em)|(?:ex));?\s*)
    static QRegularExpression regex_3(QString::fromUtf8("(font-size:\\s*[\\d]+(?:.[\\d]+)*(?:(?:px)|(?:pt)|(?:em)|(?:ex));?\\s*)"));
    html = html.replace(regex_3, QString::fromUtf8(""));

    // Filters that apply only to native sources:
    if (comesFromRecognizedNativeSource) {
        static QRegularExpression regex_4(QString::fromUtf8(
            "(?:(?:p\\s*{.*(\\scolor:\\s*#[0123456789abcdefABCDEF]{3}(?:[0123456789abcdefABCDEF]{3})?;))|(?:(?:<[bB][oO][dD][yY]\\s).*(\\s(?:(?:text)|("
            "?:v?"
            "link))=\"#[0123456789abcdefABCDEF]{3}(?:[0123456789abcdefABCDEF]{3})?\").*(\\s(?:(?:text)|(?:v?link))=\"#[0123456789abcdefABCDEF]{3}(?:["
            "0123456789abcdefABCDEF]{3})?\").*(\\s(?:(?:text)|(?:v?link))=\"#[0123456789abcdefABCDEF]{3}(?:[0123456789abcdefABCDEF]{3})?\")))"));
        // 2. Remove text color attributes from body and CSS portion.  Running it 3 times ensures text, link, and vlink attributes are removed, irregardless
        // of their order, while keeping regex maintainable Clean RegEx:
        // (?:(?:p\s*{.*(\scolor:\s*#[0123456789abcdefABCDEF]{3}(?:[0123456789abcdefABCDEF]{3})?;))|(?:(?:<[bB][oO][dD][yY]\s).*(\s(?:(?:text)|(?:v?link))="#[0123456789abcdefABCDEF]{3}(?:[0123456789abcdefABCDEF]{3})?").*(\s(?:(?:text)|(?:v?link))="#[0123456789abcdefABCDEF]{3}(?:[0123456789abcdefABCDEF]{3})?").*(\s(?:(?:text)|(?:v?link))="#[0123456789abcdefABCDEF]{3}(?:[0123456789abcdefABCDEF]{3})?")))
        html = html.replace(regex_4, QString::fromUtf8(""));
        // for (int i=0; i<3; ++i)
        //     html =
        //     html.replace(QRegularExpression("(?:(?:<[bB][oO][dD][yY]\\s).*(\\s(?:(?:text)|(?:v?link))=\"#[0123456789abcdefABCDEF]{3}(?:[0123456789abcdefABCDEF]{3})?\"))"),
        //     "");
    }
    // Filters that apply only to non-native sources:
    else // if (!comesFromRecognizedNativeSource)
    {
        // 3. Preserve highlights: Remove background color attributes from all elements except span, which is commonly used for highlights
        // Clean RegEx:
        // (?:<[^sS][^pP][^aA][^nN](?:\s*[^>]*(\s*background(?:-color)?:\s*(?:(?:rgba?\(\d\d?\d?,\s*\d\d?\d?,\s*\d\d?\d?(?:,\s*[01]?(?:[.]\d\d*)?)?\))|(?:#[0-9a-fA-F]{3}(?:[0-9a-fA-F]{3})?));?)\s*[^>]*)*>)
        static QRegularExpression regex_5(
            QString::fromUtf8("(?:<[^sS][^pP][^aA][^nN](?:\\s*[^>]*(\\s*background(?:-color)?:\\s*(?:(?:rgba?\\(\\d\\d?\\d?,\\s*\\d\\d?\\d?,\\s*\\d\\d?\\d?(?"
                              ":,\\s*[01]?(?:[.]\\d\\d*)?)?\\))|(?:#[0-9a-fA-F]{3}(?:[0-9a-fA-F]{3})?));?)\\s*[^>]*)*>)"));
        html = html.replace(regex_5, QString::fromUtf8(""));
    }
    // Manual toggle filters
    if (ignoreBlackTextColor || !comesFromRecognizedNativeSource) {
        // 4. Removal of black colored text attribute, subject to source editor.  Applies to Google Docs, OnlyOffice, Microsoft 365 Office Online and random
        // websites.  Not used in LibreOffice, OpenOffice, WPS Office nor regular MS Office. 8-bit color values bellow 100 are ignored when rgb format is
        // used. Has no effect on LibreOffice because of XML differences; nevertheless, there's no need to ignore dark text colors on LibreOffice because
        // LibreOffice has a correct implementation of default colors.
        // Clean RegEx:
        // (\s*(?:mso-style-textfill-fill-)?color:\s*(?:(?:rgba?\(\d{1,2},\s*\d{1,2},\s*\d{1,2}(?:,\s*[10]?(?:[.]00*)?)?\))|(?:black)|(?:windowtext)|(?:#0{3}(?:0{3})?));?)
        static QRegularExpression regex_6(
            QString::fromUtf8("(\\s*(?:mso-style-textfill-fill-)?color:\\s*(?:(?:rgba?\\(\\d{1,2},\\s*\\d{1,2},\\s*\\d{"
                              "1,2}(?:,\\s*[10]?(?:[.]00*)?)?\\))|(?:black)|(?:windowtext)|(?:#0{3}(?:0{3})?));?)"));
        html = html.replace(regex_6, QString::fromUtf8(""));
    }

    // Filtering complete
    // qDebug() << html;
    return html;
}

void DocumentHandler::paste(bool withoutFormating = false)
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
    } else if (mimeData->hasText())
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

QPoint DocumentHandler::replaceSelected(QString text)
{
    QTextCursor cursor = this->textCursor();
    if (cursor.selectedText().length()) {
        cursor.beginEditBlock();
        cursor.removeSelectedText();
        const int startPosition = cursor.position();
        cursor.insertText(text);
        const int endPosition = cursor.position();
        cursor.endEditBlock();
        cursor.setPosition(startPosition);
        cursor.setPosition(endPosition, QTextCursor::KeepAnchor);
        this->setSelectionStart(cursor.selectionStart());
        this->setSelectionEnd(cursor.selectionEnd());
    }
    return QPoint(this->selectionStart(), this->selectionEnd());
}

long DocumentHandler::replaceAll(const QString &searchedText, const QString &replacementText, bool regEx)
{
    long i = 0;
    if (searchedText.length() > 0) {
        QTextCursor cursor = this->textCursor();
        cursor.movePosition(QTextCursor::End);
        setSelectionStart(cursor.position()-1);
        setSelectionEnd(cursor.position());
        QPoint range = search(searchedText, false, true, regEx, false);
        bool resultsFound = range.y() > range.x();
        if (resultsFound) {
            cursor.beginEditBlock();
            do {
                i++;
                // Select result
                cursor.setPosition(range.x());
                cursor.setPosition(range.y(), QTextCursor::KeepAnchor);
                // Replace
                cursor.removeSelectedText();
                cursor.insertText(replacementText);
                // Search again
                range = search(searchedText, false, true, regEx, false);
                resultsFound = range.y() > range.x();
            } while (resultsFound);
            cursor.endEditBlock();
        }
    }
    return i;
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
QPoint DocumentHandler::search(const QString &subString, const bool next, const bool reverse, const bool regEx, const bool loop)
{
    // qDebug() << "pre" << this->cursorPosition() << this->selectionStart() << this->selectionEnd();
    QTextCursor cursor;
    if (regEx) {
        static QRegularExpression searchRegEx;
        searchRegEx.setPattern(subString);
        if (reverse)
            cursor = this->textDocument()->find(searchRegEx, this->selectionStart(), QTextDocument::FindBackward | QTextDocument::FindCaseSensitively);
        else if (next)
            cursor = this->textDocument()->find(searchRegEx, this->selectionEnd(), QTextDocument::FindCaseSensitively);
        else
            cursor = this->textDocument()->find(searchRegEx, this->selectionStart(), QTextDocument::FindCaseSensitively);
        // If no more results, go to the corresponding start position and do the search once more
        if (cursor.selectionStart() == -1 && cursor.selectionStart() == -1 && cursor.selectionEnd() == -1) {
            if (reverse)
                cursor =
                    this->textDocument()->find(searchRegEx, textDocument()->characterCount(), QTextDocument::FindBackward | QTextDocument::FindCaseSensitively);
            else
                cursor = this->textDocument()->find(searchRegEx, 0, QTextDocument::FindCaseSensitively);
        }
    } else {
        if (reverse)
            cursor = this->textDocument()->find(subString, this->selectionStart(), QTextDocument::FindBackward);
        else if (next)
            cursor = this->textDocument()->find(subString, this->selectionEnd());
        else
            cursor = this->textDocument()->find(subString, this->selectionStart());
        // If no more results, go to the corresponding start position and do the search once more
        if (loop && (cursor.selectionStart() == -1 && cursor.selectionStart() == -1 && cursor.selectionEnd() == -1)) {
            if (reverse)
                cursor = this->textDocument()->find(subString, textDocument()->characterCount(), QTextDocument::FindBackward);
            else
                cursor = this->textDocument()->find(subString, 0);
        }
    }
    // Update cursor
    if (cursor.selectionStart() != -1) {
        this->setCursorPosition(cursor.selectionStart());
        this->setSelectionStart(cursor.selectionStart());
    }
    this->setSelectionEnd(cursor.selectionEnd());
    // qDebug() << "post" << this->cursorPosition() << this->selectionStart() << this->selectionEnd() << Qt::endl;
    // Return selection range so that it can be passed to the editor
    return QPoint(this->selectionStart(), this->selectionEnd());
}

int DocumentHandler::keySearch(int key)
{
    return _markersModel->keySearch(key, cursorPosition(), false, true);
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

// Paragraph Height
void DocumentHandler::setParagraphHeight(int paragraphHeight)
{
    QTextCursor cursor = textCursor();
    if (cursor.isNull())
        return;
    cursor.joinPreviousEditBlock();
    cursor.select(QTextCursor::Document);
    QTextBlockFormat modifier = QTextBlockFormat();
    modifier.setBottomMargin(paragraphHeight);
    cursor.mergeBlockFormat(modifier);
    cursor.endEditBlock();
}

// Markers (Anchors)

void DocumentHandler::parse()
{
    struct LINE {
        QRectF rect;
        QString text;
    };

    size_t size = 1024;
    std::vector<LINE> lines;
    lines.reserve(size);

    _markersModel->clearMarkers();

    // Go through the document once
    for (QTextBlock it = this->textDocument()->begin(); it != this->textDocument()->end(); it = it.next()) {
        QTextBlock::iterator jt;

        // Navigate the document's physical layout and extract line dimensions and text. Dimensions would be used for telemetry, text would be used as a
        // reference of what to expect during speech recognition.
        for (int i = 0; i < it.layout()->lineCount(); i++) {
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
                        QString anchorName = QString::fromUtf8((*constIterator).toLocal8Bit().constData());
                        // Assign input key
                        if (anchorName.startsWith(QString::fromUtf8("key_"))) {
                            marker.key = QStringView(anchorName).mid(4).toInt();
                            QKeySequence seq = QKeySequence(marker.key);
                            marker.keyLetter = seq.toString();
                        }
                        // Assign request type
                        else if (anchorName.startsWith(QString::fromUtf8("req_")))
                            // If invalid, default to 0 (GET)
                            marker.requestType =
                                QStringView(anchorName).mid(4).toInt(); // GET request by default  // Dev: Cast to enumerator to improve readability
                        //                         qDebug() << anchorName;
                    }
                    _markersModel->appendMarker(marker);
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
    for (int i = 0; i < this->_markersModel->rowCount(); i++) {
        //         qDebug() << this->_markersModel.data(i, 0);
        // qDebug() << this->_markersModel.get(i).position << this->_markersModel.get(i).text << this->_markersModel.get(i).names;
        // qDebug() << anchors.at(i).position() << anchors.at(i).text() << anchors.at(i).charFormat().anchorNames();
        // qDebug() << i;
    }
#endif
}

Marker DocumentHandler::nextMarker(quint64 position)
{
    //     if (this->_markersModel->rowCount()==0)
    if (markersListDirty())
        parse();
    return _markersModel->nextMarker(position);
}

Marker DocumentHandler::previousMarker(quint64 position)
{
    //     if (this->_markersModel->rowCount()==0)
    if (markersListDirty())
        parse();
    return _markersModel->previousMarker(position);
}

bool DocumentHandler::preventSleep(bool prevent)
{
#if defined(Q_OS_ANDROID)
    // The following code is commented out because, even tho it's technically correct, it makes QPrompt to crash on user interaction and during automatic
    // state switching, depending on which flag is set.
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
//             const jint dimFlag = QAndroidJniObject::getStaticField<jint>("org/qtproject/qt5/android/view/WindowManager/LayoutParams", "FLAG_DIM_BEHIND"), //
//             2
//                        //blurFlag = QAndroidJniObject::getStaticField<jint>("org/qtproject/qt5/android/view/WindowManager/LayoutParams", "FLAG_BLUR_BEHIND"),
//                        // 4 screenFlag = QAndroidJniObject::getStaticField<jint>("org/qtproject/qt5/android/view/WindowManager/LayoutParams",
//                        "FLAG_KEEP_SCREEN_ON"); // 128
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
//     return prevent;
#elif defined(Q_OS_IOS)
    // To be implemented...
#endif
    // Not implemented for this operating system, always return false.
    // Using "prevent" in fallacy statement to clear unused variable warnings. There's probably a better way of implementing this in which this method
    // doesn't get compiled. Nevertheless, the QML layer needs something to invoke.
    return false & prevent;
}
