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

class Hunspell;

class SpellChecker
{
public:
    explicit SpellChecker(const QString &language = QStringLiteral("en_US"));
    ~SpellChecker();

    bool setLanguage(const QString &language);
    QString language() const { return m_language; }

    bool isValid() const { return m_hunspell != nullptr; }

    bool spell(const QString &word) const;
    QStringList suggest(const QString &word) const;
    void addWord(const QString &word);

private:
    bool load(const QString &language);
    void unload();
    static QString locateDictionary(const QString &language, const QString &extension);

    QByteArray encode(const QString &word) const;
    QString decode(const std::string &word) const;

    Hunspell *m_hunspell = nullptr;
    QString m_language;
    QByteArray m_encoding;
};
