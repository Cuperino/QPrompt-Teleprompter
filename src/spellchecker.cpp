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

#include <QCoreApplication>
#include <QDebug>
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QStandardPaths>

#include <hunspell/hunspell.hxx>

SpellChecker::SpellChecker(const QString &language)
{
    load(language);
}

SpellChecker::~SpellChecker()
{
    unload();
}

bool SpellChecker::setLanguage(const QString &language)
{
    if (language == m_language && m_hunspell)
        return true;
    unload();
    return load(language);
}

bool SpellChecker::spell(const QString &word) const
{
    if (!m_hunspell || word.isEmpty())
        return true;
    return m_hunspell->spell(encode(word).toStdString());
}

QStringList SpellChecker::suggest(const QString &word) const
{
    QStringList out;
    if (!m_hunspell || word.isEmpty())
        return out;
    const auto results = m_hunspell->suggest(encode(word).toStdString());
    out.reserve(static_cast<int>(results.size()));
    for (const auto &s : results)
        out.append(decode(s));
    return out;
}

void SpellChecker::addWord(const QString &word)
{
    if (!m_hunspell || word.isEmpty())
        return;
    m_hunspell->add(encode(word).toStdString());
}

bool SpellChecker::load(const QString &language)
{
    const QString aff = locateDictionary(language, QStringLiteral("aff"));
    const QString dic = locateDictionary(language, QStringLiteral("dic"));
    if (aff.isEmpty() || dic.isEmpty()) {
        qWarning() << "SpellChecker: could not locate dictionary for" << language;
        return false;
    }
    const QByteArray affPath = aff.toLocal8Bit();
    const QByteArray dicPath = dic.toLocal8Bit();
    m_hunspell = new Hunspell(affPath.constData(), dicPath.constData());
    m_language = language;
    const char *enc = m_hunspell->get_dict_encoding().c_str();
    m_encoding = QByteArray(enc);
    return true;
}

void SpellChecker::unload()
{
    delete m_hunspell;
    m_hunspell = nullptr;
    m_language.clear();
    m_encoding.clear();
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

QByteArray SpellChecker::encode(const QString &word) const
{
    if (m_encoding.isEmpty() || m_encoding.compare("UTF-8", Qt::CaseInsensitive) == 0)
        return word.toUtf8();
    // Fallback to Latin-1 for legacy single-byte dictionaries (e.g. ISO8859-1).
    return word.toLocal8Bit();
}

QString SpellChecker::decode(const std::string &word) const
{
    if (m_encoding.isEmpty() || m_encoding.compare("UTF-8", Qt::CaseInsensitive) == 0)
        return QString::fromUtf8(word.c_str(), static_cast<int>(word.size()));
    return QString::fromLocal8Bit(word.c_str(), static_cast<int>(word.size()));
}
