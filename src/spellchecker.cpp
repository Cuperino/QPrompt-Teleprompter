/****************************************************************************
 **
 ** QPrompt
 ** Copyright (C) 2020-2026 Javier O. Cordero Pérez
 **
 ** This file is part of QPrompt.
 **
 ** This program is free software: you can redistribute it and/or modify
 ** it under the terms of the GNU General Public License as published by
 ** the Free Software Foundation, version 3 of the License.
 **
 ****************************************************************************/

#include "spellchecker.h"

#include <QCollator>
#include <QCoreApplication>
#include <QDebug>
#include <QDir>
#include <QDirIterator>
#include <QFile>
#include <QFileInfo>
#include <QSet>
#include <QStandardPaths>
#include <QTextStream>

#include <hunspell/hunspell.hxx>

SpellChecker::SpellChecker(const QString &language)
{
    loadCustomWordsFromDisk();
    setLanguage(language);
}

SpellChecker::~SpellChecker()
{
    unload();
}

bool SpellChecker::setLanguage(const QString &language)
{
    return setLanguages(QStringList{language});
}

bool SpellChecker::setLanguages(const QStringList &languages)
{
    unload();
    bool anyLoaded = false;
    QStringList seen;
    for (const QString &lang : languages) {
        if (lang.isEmpty() || seen.contains(lang))
            continue;
        seen.append(lang);
        Dictionary d;
        if (loadOne(lang, d)) {
            m_dicts.push_back(std::move(d));
            anyLoaded = true;
        }
    }
    return anyLoaded;
}

QStringList SpellChecker::languages() const
{
    QStringList out;
    out.reserve(static_cast<int>(m_dicts.size()));
    for (const auto &d : m_dicts)
        out.append(d.language);
    return out;
}

bool SpellChecker::spell(const QString &word) const
{
    if (m_dicts.empty() || word.isEmpty())
        return true;
    for (const auto &d : m_dicts) {
        if (d.hunspell->spell(encode(d, word).toStdString()))
            return true;
    }
    return false;
}

QStringList SpellChecker::suggest(const QString &word) const
{
    QStringList out;
    if (m_dicts.empty() || word.isEmpty())
        return out;
    QSet<QString> seen;
    for (const auto &d : m_dicts) {
        const auto results = d.hunspell->suggest(encode(d, word).toStdString());
        for (const auto &s : results) {
            const QString decoded = decode(d, s);
            if (!seen.contains(decoded)) {
                seen.insert(decoded);
                out.append(decoded);
            }
        }
    }
    return out;
}

void SpellChecker::addWord(const QString &word)
{
    if (m_dicts.empty() || word.isEmpty())
        return;
    for (auto &d : m_dicts)
        d.hunspell->add(encode(d, word).toStdString());
}

bool SpellChecker::loadOne(const QString &language, Dictionary &out)
{
    const QString aff = locateDictionary(language, QStringLiteral("aff"));
    const QString dic = locateDictionary(language, QStringLiteral("dic"));
    if (aff.isEmpty() || dic.isEmpty()) {
        qWarning() << "SpellChecker: could not locate dictionary for" << language;
        return false;
    }
    const QByteArray affPath = aff.toLocal8Bit();
    const QByteArray dicPath = dic.toLocal8Bit();
    out.hunspell.reset(new Hunspell(affPath.constData(), dicPath.constData()));
    out.language = language;
    const char *enc = out.hunspell->get_dict_encoding().c_str();
    out.encoding = QByteArray(enc);

    applyBuiltInWords(out);
    applyCustomWords(out);
    return true;
}

void SpellChecker::applyBuiltInWords(Dictionary &d)
{
    static const QStringList appDictionary = {
        QStringLiteral("QPrompt"),
        QStringLiteral("QPrompt's"),
        QStringLiteral("Cuperino"),
        QStringLiteral("Cordero"),
        QStringLiteral("KDE"),
        QStringLiteral("KDAB"),
    };
    for (const QString &w : appDictionary)
        d.hunspell->add(encode(d, w).toStdString());
}

void SpellChecker::applyCustomWords(Dictionary &d)
{
    for (const QString &w : m_customWords)
        d.hunspell->add(encode(d, w).toStdString());
}

void SpellChecker::unload()
{
    m_dicts.clear();
}

QString SpellChecker::locateDictionary(const QString &language, const QString &extension)
{
    const QString fileName = QStringLiteral("%1.%2").arg(language, extension);

    // 1) Qt resource (bundled with the app, if provided)
    const QString resourcePath = QStringLiteral(":/dictionaries/") + fileName;
    if (QFile::exists(resourcePath)) {
        // Hunspell cannot read from Qt resources; copy to a writable cache.
        const QString cacheDir = QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation) + QStringLiteral("/dictionaries");
        QDir().mkpath(cacheDir);
        const QString outPath = cacheDir + QLatin1Char('/') + fileName;
        if (!QFile::exists(outPath)) {
            QFile::copy(resourcePath, outPath);
            QFile::setPermissions(outPath, QFile::ReadOwner | QFile::WriteOwner | QFile::ReadGroup | QFile::ReadOther);
        }
        return outPath;
    }

    // 2) User-writable local data dir (manual install)
    const QStringList dataDirs = QStandardPaths::standardLocations(QStandardPaths::GenericDataLocation)
        + QStandardPaths::standardLocations(QStandardPaths::AppLocalDataLocation);
    const QStringList subDirs = {
        QStringLiteral("hunspell"),
        QStringLiteral("myspell/dicts"),
        QStringLiteral("myspell"),
        QStringLiteral("dictionaries"),
    };
    for (const QString &base : dataDirs) {
        for (const QString &sub : subDirs) {
            const QString candidate = base + QLatin1Char('/') + sub + QLatin1Char('/') + fileName;
            if (QFileInfo::exists(candidate))
                return candidate;
        }
    }

    // 3) Common system paths (Linux/BSD)
    const QStringList systemPaths = {
        QStringLiteral("/usr/share/hunspell/"),
        QStringLiteral("/usr/share/myspell/dicts/"),
        QStringLiteral("/usr/share/myspell/"),
        QStringLiteral("/usr/local/share/hunspell/"),
        QStringLiteral("/usr/local/share/myspell/"),
    };
    for (const QString &p : systemPaths) {
        const QString candidate = p + fileName;
        if (QFileInfo::exists(candidate))
            return candidate;
    }

    return QString();
}

QStringList SpellChecker::availableDictionaries()
{
    QSet<QString> found;

    auto scanDir = [&](const QString &path) {
        QDir dir(path);
        if (!dir.exists())
            return;
        const QStringList entries = dir.entryList(QStringList{QStringLiteral("*.dic")}, QDir::Files);
        for (const QString &entry : entries) {
            const QString base = QFileInfo(entry).completeBaseName();
            if (!base.isEmpty())
                found.insert(base);
        }
    };

    // Bundled resources (enumerate via QDirIterator over Qt resource)
    {
        QDirIterator it(QStringLiteral(":/dictionaries"), QStringList{QStringLiteral("*.dic")}, QDir::Files);
        while (it.hasNext()) {
            it.next();
            const QString base = QFileInfo(it.fileName()).completeBaseName();
            if (!base.isEmpty())
                found.insert(base);
        }
    }

    const QStringList dataDirs = QStandardPaths::standardLocations(QStandardPaths::GenericDataLocation)
        + QStandardPaths::standardLocations(QStandardPaths::AppLocalDataLocation);
    const QStringList subDirs = {
        QStringLiteral("hunspell"),
        QStringLiteral("myspell/dicts"),
        QStringLiteral("myspell"),
        QStringLiteral("dictionaries"),
    };
    for (const QString &base : dataDirs)
        for (const QString &sub : subDirs)
            scanDir(base + QLatin1Char('/') + sub);

    const QStringList systemPaths = {
        QStringLiteral("/usr/share/hunspell"),
        QStringLiteral("/usr/share/myspell/dicts"),
        QStringLiteral("/usr/share/myspell"),
        QStringLiteral("/usr/local/share/hunspell"),
        QStringLiteral("/usr/local/share/myspell"),
    };
    for (const QString &p : systemPaths)
        scanDir(p);

    QStringList out = found.values();
    QCollator collator;
    collator.setCaseSensitivity(Qt::CaseInsensitive);
    std::sort(out.begin(), out.end(), [&collator](const QString &a, const QString &b) {
        return collator.compare(a, b) < 0;
    });
    return out;
}

bool SpellChecker::addCustomWord(const QString &word)
{
    const QString trimmed = word.trimmed();
    if (trimmed.isEmpty())
        return false;
    if (m_customWords.contains(trimmed))
        return false;
    m_customWords.append(trimmed);
    QCollator collator;
    collator.setCaseSensitivity(Qt::CaseInsensitive);
    std::sort(m_customWords.begin(), m_customWords.end(), [&collator](const QString &a, const QString &b) {
        return collator.compare(a, b) < 0;
    });
    for (auto &d : m_dicts)
        d.hunspell->add(encode(d, trimmed).toStdString());
    saveCustomWordsToDisk();
    return true;
}

bool SpellChecker::removeCustomWord(const QString &word)
{
    const int idx = m_customWords.indexOf(word);
    if (idx < 0)
        return false;
    m_customWords.removeAt(idx);
    // Hunspell has remove(); reapply state by reloading dictionaries so the
    // removed word is no longer accepted.
    const QStringList langs = languages();
    saveCustomWordsToDisk();
    if (!langs.isEmpty()) {
        // Reload to drop the word from the in-memory dictionaries.
        unload();
        for (const QString &lang : langs) {
            Dictionary d;
            if (loadOne(lang, d))
                m_dicts.push_back(std::move(d));
        }
    }
    return true;
}

QString SpellChecker::customWordsPath()
{
    const QString dir = QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation);
    QDir().mkpath(dir);
    return dir + QStringLiteral("/custom-dictionary.txt");
}

void SpellChecker::loadCustomWordsFromDisk()
{
    m_customWords.clear();
    QFile file(customWordsPath());
    if (!file.exists() || !file.open(QIODevice::ReadOnly | QIODevice::Text))
        return;
    QTextStream in(&file);
    in.setEncoding(QStringConverter::Utf8);
    while (!in.atEnd()) {
        const QString line = in.readLine().trimmed();
        if (!line.isEmpty() && !m_customWords.contains(line))
            m_customWords.append(line);
    }
    QCollator collator;
    collator.setCaseSensitivity(Qt::CaseInsensitive);
    std::sort(m_customWords.begin(), m_customWords.end(), [&collator](const QString &a, const QString &b) {
        return collator.compare(a, b) < 0;
    });
}

void SpellChecker::saveCustomWordsToDisk() const
{
    QFile file(customWordsPath());
    if (!file.open(QIODevice::WriteOnly | QIODevice::Text | QIODevice::Truncate))
        return;
    QTextStream out(&file);
    out.setEncoding(QStringConverter::Utf8);
    for (const QString &w : m_customWords)
        out << w << '\n';
}

QByteArray SpellChecker::encode(const Dictionary &d, const QString &word) const
{
    if (d.encoding.isEmpty() || d.encoding.compare("UTF-8", Qt::CaseInsensitive) == 0)
        return word.toUtf8();
    // Fallback to Latin-1 for legacy single-byte dictionaries (e.g. ISO8859-1).
    return word.toLocal8Bit();
}

QString SpellChecker::decode(const Dictionary &d, const std::string &word) const
{
    if (d.encoding.isEmpty() || d.encoding.compare("UTF-8", Qt::CaseInsensitive) == 0)
        return QString::fromUtf8(word.c_str(), static_cast<int>(word.size()));
    return QString::fromLocal8Bit(word.c_str(), static_cast<int>(word.size()));
}
