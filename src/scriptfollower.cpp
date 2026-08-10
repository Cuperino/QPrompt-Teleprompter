/****************************************************************************
 **
 ** QPrompt
 ** Copyright (C) 2026 Javier O. Cordero Perez
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

#include "scriptfollower.h"

#include <QHash>
#include <QRegularExpression>

#include <algorithm>
#include <cstdlib>
#include <limits>

namespace {
constexpr int MaximumHypothesisTokens = 18;
constexpr int MismatchPenalty = 3;
constexpr int GapPenalty = 2;
constexpr int MinimumStableMatches = 2;
constexpr int MinimumStableEvidence = 7;
constexpr qreal MinimumStableConfidence = 0.58;
constexpr int MinimumBackwardMatches = 4;
constexpr qreal MinimumBackwardConfidence = 0.80;

QString normalizeToken(QString token)
{
    token.replace(QChar(0x2019), QLatin1Char('\''));
    return token.toCaseFolded();
}
}

ScriptFollower::ScriptFollower(QObject *parent)
    : QObject(parent)
{
}

QString ScriptFollower::script() const
{
    return m_script;
}

void ScriptFollower::setScript(const QString &script)
{
    if (m_script == script)
        return;

    m_script = script;
    m_tokens = tokenize(m_script, true);
    m_visibleStart = 0;
    m_visibleEnd = static_cast<int>(m_script.size());
    m_position = 0;
    m_confidence = 0.0;
    m_stable = false;
    rebuildTrackingWindow();

    Q_EMIT scriptChanged();
    Q_EMIT matchChanged();
}

int ScriptFollower::position() const
{
    return m_position;
}

qreal ScriptFollower::confidence() const
{
    return m_confidence;
}

bool ScriptFollower::stable() const
{
    return m_stable;
}

int ScriptFollower::lookBackTokens() const
{
    return m_lookBackTokens;
}

void ScriptFollower::setLookBackTokens(int count)
{
    count = std::max(0, count);
    if (m_lookBackTokens == count)
        return;

    m_lookBackTokens = count;
    rebuildTrackingWindow();
    Q_EMIT windowConfigurationChanged();
}

int ScriptFollower::lookAheadTokens() const
{
    return m_lookAheadTokens;
}

void ScriptFollower::setLookAheadTokens(int count)
{
    count = std::max(0, count);
    if (m_lookAheadTokens == count)
        return;

    m_lookAheadTokens = count;
    rebuildTrackingWindow();
    Q_EMIT windowConfigurationChanged();
}

void ScriptFollower::setTrackingWindow(int firstVisibleCharacter, int lastVisibleCharacter)
{
    if (firstVisibleCharacter > lastVisibleCharacter)
        std::swap(firstVisibleCharacter, lastVisibleCharacter);

    const int scriptLength = static_cast<int>(m_script.size());
    m_visibleStart = std::clamp(firstVisibleCharacter, 0, scriptLength);
    m_visibleEnd = std::clamp(lastVisibleCharacter, m_visibleStart, scriptLength);
    rebuildTrackingWindow();
}

void ScriptFollower::reset(int documentPosition)
{
    const int boundedPosition = std::clamp(documentPosition, 0, static_cast<int>(m_script.size()));
    updateMatchState(0.0, false, boundedPosition);
}

int ScriptFollower::positionAfterTokens(int documentPosition, int tokenCount) const
{
    if (m_tokens.isEmpty())
        return std::clamp(documentPosition, 0, static_cast<int>(m_script.size()));

    const int currentToken = tokenAtOrAfter(documentPosition);
    const int targetToken = std::clamp(currentToken + std::max(0, tokenCount),
        0, static_cast<int>(m_tokens.size()) - 1);
    return m_tokens.at(targetToken).position;
}

QVariantMap ScriptFollower::acceptPartialTranscript(const QString &transcript)
{
    QVector<Token> recognizedTokens = tokenize(transcript, false);
    if (recognizedTokens.size() > MaximumHypothesisTokens)
        recognizedTokens = recognizedTokens.mid(recognizedTokens.size() - MaximumHypothesisTokens);

    const AlignmentResult result = align(recognizedTokens);
    int candidatePosition = -1;
    if (result.tokenIndex >= 0)
        candidatePosition = m_tokens.at(result.tokenIndex).position;

    if (result.stable)
        updateMatchState(result.confidence, true, candidatePosition);
    else
        updateMatchState(result.confidence, false, m_position);

    return {
        {QStringLiteral("position"), m_position},
        {QStringLiteral("candidatePosition"), candidatePosition},
        {QStringLiteral("confidence"), result.confidence},
        {QStringLiteral("stable"), result.stable},
        {QStringLiteral("matchedTokens"), result.matches},
    };
}

QVector<ScriptFollower::Token> ScriptFollower::tokenize(const QString &text, bool retainPositions)
{
    static const QRegularExpression wordExpression(
        QStringLiteral("[\\p{L}\\p{M}\\p{N}]+(?:['\\x{2019}][\\p{L}\\p{M}\\p{N}]+)*"),
        QRegularExpression::UseUnicodePropertiesOption);

    QVector<Token> tokens;
    QRegularExpressionMatchIterator iterator = wordExpression.globalMatch(text);
    while (iterator.hasNext()) {
        const QRegularExpressionMatch match = iterator.next();
        Token token;
        token.normalized = normalizeToken(match.captured());
        if (retainPositions) {
            token.position = match.capturedStart();
            token.length = match.capturedLength();
        }
        tokens.append(token);
    }
    return tokens;
}

int ScriptFollower::tokenWeight(const QString &token, int frequency)
{
    int weight = token.size() <= 2 ? 2 : token.size() <= 4 ? 3 : 4;
    if (frequency == 1)
        ++weight;
    return weight;
}

int ScriptFollower::tokenAtOrAfter(int documentPosition) const
{
    if (m_tokens.isEmpty())
        return -1;

    const auto iterator = std::lower_bound(m_tokens.cbegin(), m_tokens.cend(), documentPosition,
        [](const Token &token, int position) {
            return token.position + token.length <= position;
        });

    if (iterator == m_tokens.cend())
        return static_cast<int>(m_tokens.size()) - 1;
    return static_cast<int>(std::distance(m_tokens.cbegin(), iterator));
}

void ScriptFollower::rebuildTrackingWindow()
{
    if (m_tokens.isEmpty()) {
        m_windowStartToken = -1;
        m_windowEndToken = -1;
        return;
    }

    const int firstVisibleToken = tokenAtOrAfter(m_visibleStart);
    int lastVisibleToken = tokenAtOrAfter(m_visibleEnd);
    if (lastVisibleToken > 0 && m_tokens.at(lastVisibleToken).position >= m_visibleEnd)
        --lastVisibleToken;
    lastVisibleToken = std::max(firstVisibleToken, lastVisibleToken);

    m_windowStartToken = std::max(0, firstVisibleToken - m_lookBackTokens);
    m_windowEndToken = std::min(static_cast<int>(m_tokens.size()) - 1, lastVisibleToken + m_lookAheadTokens);
}

ScriptFollower::AlignmentResult ScriptFollower::align(const QVector<Token> &recognizedTokens) const
{
    AlignmentResult result;
    if (recognizedTokens.isEmpty() || m_windowStartToken < 0 || m_windowEndToken < m_windowStartToken)
        return result;

    const int scriptTokenCount = m_windowEndToken - m_windowStartToken + 1;
    QHash<QString, int> frequencies;
    for (int index = m_windowStartToken; index <= m_windowEndToken; ++index)
        ++frequencies[m_tokens.at(index).normalized];

    QVector<AlignmentCell> previous(scriptTokenCount + 1);
    QVector<AlignmentCell> current(scriptTokenCount + 1);
    int bestToken = -1;
    const int anchorToken = tokenAtOrAfter(m_position);

    for (int recognizedIndex = 1; recognizedIndex <= recognizedTokens.size(); ++recognizedIndex) {
        current.fill(AlignmentCell());
        for (int scriptIndex = 1; scriptIndex <= scriptTokenCount; ++scriptIndex) {
            const Token &recognized = recognizedTokens.at(recognizedIndex - 1);
            const Token &scriptToken = m_tokens.at(m_windowStartToken + scriptIndex - 1);
            const bool isMatch = recognized.normalized == scriptToken.normalized;
            const int weight = tokenWeight(scriptToken.normalized, frequencies.value(scriptToken.normalized));

            AlignmentCell diagonal = previous.at(scriptIndex - 1);
            diagonal.score += isMatch ? weight : -MismatchPenalty;
            if (isMatch) {
                ++diagonal.matches;
                diagonal.evidence += weight;
            }

            AlignmentCell skipRecognized = previous.at(scriptIndex);
            skipRecognized.score -= GapPenalty;

            AlignmentCell skipScript = current.at(scriptIndex - 1);
            skipScript.score -= GapPenalty;

            AlignmentCell best;
            if (diagonal.score > best.score)
                best = diagonal;
            if (skipRecognized.score > best.score)
                best = skipRecognized;
            if (skipScript.score > best.score)
                best = skipScript;
            current[scriptIndex] = best;

            const int absoluteToken = m_windowStartToken + scriptIndex - 1;
            const int candidateDistance = std::abs(absoluteToken - anchorToken);
            const int bestDistance = bestToken < 0 ? std::numeric_limits<int>::max() : std::abs(bestToken - anchorToken);
            if (best.score > result.score
                || (best.score == result.score && best.matches > result.matches)
                || (best.score == result.score && best.matches == result.matches && candidateDistance < bestDistance)) {
                result.score = best.score;
                result.matches = best.matches;
                result.evidence = best.evidence;
                bestToken = absoluteToken;
            }
        }
        previous.swap(current);
    }

    result.tokenIndex = bestToken;
    if (result.evidence > 0) {
        const qreal alignmentQuality = std::clamp(static_cast<qreal>(result.score) / result.evidence, 0.0, 1.0);
        const qreal evidenceStrength = std::min(1.0, static_cast<qreal>(result.evidence) / 12.0);
        result.confidence = 0.65 * alignmentQuality + 0.35 * evidenceStrength;
    }

    result.stable = result.matches >= MinimumStableMatches
        && result.evidence >= MinimumStableEvidence
        && result.confidence >= MinimumStableConfidence;

    if (result.stable && result.tokenIndex < anchorToken) {
        result.stable = result.matches >= MinimumBackwardMatches
            && result.confidence >= MinimumBackwardConfidence;
    }

    return result;
}

void ScriptFollower::updateMatchState(qreal confidence, bool stable, int position)
{
    confidence = std::clamp(confidence, 0.0, 1.0);
    position = std::clamp(position, 0, static_cast<int>(m_script.size()));
    if (qFuzzyCompare(m_confidence, confidence) && m_stable == stable && m_position == position)
        return;

    m_confidence = confidence;
    m_stable = stable;
    m_position = position;
    Q_EMIT matchChanged();
}
