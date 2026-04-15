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

#include "spellhighlighter.h"
#include "spellchecker.h"

#include <QChar>
#include <QDebug>
#include <QRegularExpression>
#include <QRegularExpressionMatchIterator>

SpellHighlighter::SpellHighlighter(SpellChecker *checker, QObject *parent)
    : QSyntaxHighlighter(parent)
    , m_checker(checker)
{
    m_misspelledFormat.setUnderlineStyle(QTextCharFormat::SingleUnderline);
    m_misspelledFormat.setUnderlineColor(Qt::red);
    m_misspelledFormat.setFontUnderline(true);
}

void SpellHighlighter::setEnabled(bool enabled)
{
    if (enabled == m_enabled)
        return;
    m_enabled = enabled;
    rehighlight();
}

void SpellHighlighter::highlightBlock(const QString &text)
{
    if (!m_enabled || !m_checker || !m_checker->isValid() || text.isEmpty())
        return;

    // Match runs of letters (Unicode-aware), optionally containing apostrophes or hyphens between letters.
    static const QRegularExpression wordRe(
        QStringLiteral("\\p{L}+(?:[\\x{0027}\\x{2019}\\-]\\p{L}+)*"));

    QRegularExpressionMatchIterator it = wordRe.globalMatch(text);
    while (it.hasNext()) {
        const QRegularExpressionMatch m = it.next();
        const QString word = m.captured(0);
        if (!m_checker->spell(word))
            setFormat(m.capturedStart(0), m.capturedLength(0), m_misspelledFormat);
    }
}
