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

#include <QSyntaxHighlighter>
#include <QTextCharFormat>

class SpellChecker;

class SpellHighlighter : public QSyntaxHighlighter
{
    Q_OBJECT
public:
    explicit SpellHighlighter(SpellChecker *checker, QObject *parent = nullptr);

    void setEnabled(bool enabled);
    bool isEnabled() const { return m_enabled; }

protected:
    void highlightBlock(const QString &text) override;

private:
    SpellChecker *m_checker;
    QTextCharFormat m_misspelledFormat;
    bool m_enabled = true;
};
