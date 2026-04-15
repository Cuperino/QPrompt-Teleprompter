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

#pragma once

#include <QByteArray>
#include <QString>
#include <QStringList>
#include <memory>
#include <vector>

class Hunspell;

class SpellChecker
{
public:
    explicit SpellChecker(const QString &language = QStringLiteral("en_US"));
    ~SpellChecker();

    bool setLanguage(const QString &language);
    QString language() const { return m_dicts.empty() ? QString() : m_dicts.front().language; }

    bool setLanguages(const QStringList &languages);
    QStringList languages() const;

    bool isValid() const { return !m_dicts.empty(); }

    bool spell(const QString &word) const;
    QStringList suggest(const QString &word) const;
    void addWord(const QString &word);

    static QStringList availableDictionaries();

    QStringList customWords() const { return m_customWords; }
    bool addCustomWord(const QString &word);
    bool removeCustomWord(const QString &word);

private:
    struct Dictionary {
        std::unique_ptr<Hunspell> hunspell;
        QString language;
        QByteArray encoding;
    };

    bool loadOne(const QString &language, Dictionary &out);
    void unload();
    static QString locateDictionary(const QString &language, const QString &extension);

    QByteArray encode(const Dictionary &d, const QString &word) const;
    QString decode(const Dictionary &d, const std::string &word) const;

    void applyBuiltInWords(Dictionary &d);
    void applyCustomWords(Dictionary &d);
    void loadCustomWordsFromDisk();
    void saveCustomWordsToDisk() const;
    static QString customWordsPath();

    std::vector<Dictionary> m_dicts;
    QStringList m_customWords;
};
