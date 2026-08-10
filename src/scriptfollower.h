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

#pragma once

#include <QObject>
#include <QQmlEngine>
#include <QString>
#include <QVariantMap>
#include <QVector>

class ScriptFollower : public QObject
{
    Q_OBJECT
    QML_ELEMENT

    Q_PROPERTY(QString script READ script WRITE setScript NOTIFY scriptChanged)
    Q_PROPERTY(int position READ position NOTIFY matchChanged)
    Q_PROPERTY(qreal confidence READ confidence NOTIFY matchChanged)
    Q_PROPERTY(bool stable READ stable NOTIFY matchChanged)
    Q_PROPERTY(int lookBackTokens READ lookBackTokens WRITE setLookBackTokens NOTIFY windowConfigurationChanged)
    Q_PROPERTY(int lookAheadTokens READ lookAheadTokens WRITE setLookAheadTokens NOTIFY windowConfigurationChanged)

public:
    explicit ScriptFollower(QObject *parent = nullptr);

    QString script() const;
    void setScript(const QString &script);

    int position() const;
    qreal confidence() const;
    bool stable() const;

    int lookBackTokens() const;
    void setLookBackTokens(int count);
    int lookAheadTokens() const;
    void setLookAheadTokens(int count);

    // The range is expressed in QTextDocument character offsets. The matcher
    // considers this range plus the configured local look-back/look-ahead.
    Q_INVOKABLE void setTrackingWindow(int firstVisibleCharacter, int lastVisibleCharacter);
    Q_INVOKABLE void reset(int documentPosition = 0);
    Q_INVOKABLE int positionAfterTokens(int documentPosition, int tokenCount) const;

    // Accepts a recognizer's current partial hypothesis. The returned map is
    // convenient for diagnostics and QML prototypes; trusted results are also
    // exposed through the position/confidence/stable properties.
    Q_INVOKABLE QVariantMap acceptPartialTranscript(const QString &transcript);

Q_SIGNALS:
    void scriptChanged();
    void matchChanged();
    void windowConfigurationChanged();

private:
    struct Token {
        QString normalized;
        int position = 0;
        int length = 0;
    };

    struct AlignmentCell {
        int score = 0;
        int matches = 0;
        int evidence = 0;
    };

    struct AlignmentResult {
        int tokenIndex = -1;
        int score = 0;
        int matches = 0;
        int evidence = 0;
        qreal confidence = 0.0;
        bool stable = false;
    };

    static QVector<Token> tokenize(const QString &text, bool retainPositions);
    static int tokenWeight(const QString &token, int frequency);

    int tokenAtOrAfter(int documentPosition) const;
    void rebuildTrackingWindow();
    AlignmentResult align(const QVector<Token> &recognizedTokens) const;
    void updateMatchState(qreal confidence, bool stable, int position);

    QString m_script;
    QVector<Token> m_tokens;

    int m_position = 0;
    qreal m_confidence = 0.0;
    bool m_stable = false;

    int m_visibleStart = 0;
    int m_visibleEnd = 0;
    int m_windowStartToken = -1;
    int m_windowEndToken = -1;
    int m_lookBackTokens = 12;
    int m_lookAheadTokens = 48;
};
