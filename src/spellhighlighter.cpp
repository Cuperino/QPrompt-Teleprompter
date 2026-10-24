/****************************************************************************
 **
 ** QPrompt
 ** Copyright (C) 2026 Javier O. Cordero Pérez
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

#include "spellhighlighter.h"
#include "spellchecker.h"

#include <QChar>
#include <QDebug>
#include <QRegularExpression>
#include <QRegularExpressionMatchIterator>
#include <QTextBlock>
#include <QTextFragment>
#include <QVarLengthArray>

#include <utility>

SpellHighlighter::SpellHighlighter(SpellChecker *checker, QObject *parent)
    : QSyntaxHighlighter(parent)
    , m_checker(checker)
{
    m_misspelledFormat.setUnderlineStyle(QTextCharFormat::WaveUnderline);
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

    QVarLengthArray<std::pair<int, int>, 8> misspelled;
    QRegularExpressionMatchIterator it = wordRe.globalMatch(text);
    while (it.hasNext()) {
        const QRegularExpressionMatch m = it.next();
        if (!m_checker->spell(m.captured(0)))
            misspelled.append({m.capturedStart(0), m.capturedLength(0)});
    }
    if (misspelled.isEmpty())
        return;

#if QT_VERSION >= QT_VERSION_CHECK(6, 12, 0)
    // Qt Quick 6.12's QQuickTextNodeEngine appends the document's own background/underline
    // ranges after the highlighter's ranges and then walks them assuming they are sorted, so
    // document highlights that start before a misspelled word are dropped. Re-emit those
    // properties from the highlighter so the ranges Qt Quick sees are already ordered.
    const QTextBlock block = currentBlock();
    for (QTextBlock::iterator fit = block.begin(); !fit.atEnd(); ++fit) {
        const QTextFragment fragment = fit.fragment();
        if (!fragment.isValid())
            continue;
        const QTextCharFormat docFormat = fragment.charFormat();
        QTextCharFormat mirrored;
        for (const int property : {int(QTextFormat::BackgroundBrush), int(QTextFormat::TextUnderlineColor),
                                   int(QTextFormat::TextUnderlineStyle)}) {
            if (docFormat.hasProperty(property))
                mirrored.setProperty(property, docFormat.property(property));
        }
        if (mirrored.propertyCount() > 0)
            setFormat(fragment.position() - block.position(), fragment.length(), mirrored);
    }
#endif

    // Merge per character so a misspelled word keeps any background mirrored above.
    for (const auto &[start, length] : misspelled) {
        for (int i = start; i < start + length; ++i) {
            QTextCharFormat f = format(i);
            f.merge(m_misspelledFormat);
            setFormat(i, 1, f);
        }
    }
}
