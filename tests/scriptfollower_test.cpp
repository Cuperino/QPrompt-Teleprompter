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
 ****************************************************************************/

#include "scriptfollower.h"

#include <QtTest>

class ScriptFollowerTest : public QObject
{
    Q_OBJECT

private Q_SLOTS:
    void followsExactLocalSpeech();
    void toleratesRecognitionErrors();
    void holdsOnWeakEvidence();
    void respectsTheTrackingWindow();
    void reacquiresAfterNearbySkip();
    void normalizesApostrophesAndCase();
    void rejectsWeakBackwardMovement();
    void providesBoundedReadingLead();
};

void ScriptFollowerTest::followsExactLocalSpeech()
{
    ScriptFollower follower;
    const QString script = QStringLiteral("One two three four five.");
    follower.setScript(script);
    follower.setTrackingWindow(0, script.size());

    const QVariantMap result = follower.acceptPartialTranscript(QStringLiteral("one two three"));

    QVERIFY(result.value(QStringLiteral("stable")).toBool());
    QCOMPARE(follower.position(), script.indexOf(QStringLiteral("three")));
}

void ScriptFollowerTest::providesBoundedReadingLead()
{
    const QString script = QStringLiteral("one two three four five six");
    ScriptFollower follower;
    follower.setScript(script);

    QCOMPARE(follower.positionAfterTokens(script.indexOf(QStringLiteral("two")), 3),
        script.indexOf(QStringLiteral("five")));
    QCOMPARE(follower.positionAfterTokens(script.indexOf(QStringLiteral("five")), 20),
        script.indexOf(QStringLiteral("six")));
    QCOMPARE(follower.positionAfterTokens(script.indexOf(QStringLiteral("three")), -2),
        script.indexOf(QStringLiteral("three")));
}

void ScriptFollowerTest::toleratesRecognitionErrors()
{
    ScriptFollower follower;
    const QString script = QStringLiteral("The quick brown fox jumps over the lazy dog.");
    follower.setScript(script);
    follower.setTrackingWindow(0, script.size());

    const QVariantMap result = follower.acceptPartialTranscript(QStringLiteral("quick crown fox jumps over lazy"));

    QVERIFY(result.value(QStringLiteral("stable")).toBool());
    QCOMPARE(follower.position(), script.indexOf(QStringLiteral("lazy")));
}

void ScriptFollowerTest::holdsOnWeakEvidence()
{
    ScriptFollower follower;
    const QString script = QStringLiteral("First visible sentence with several words.");
    follower.setScript(script);
    follower.setTrackingWindow(0, script.size());
    follower.reset(script.indexOf(QStringLiteral("visible")));

    const QVariantMap result = follower.acceptPartialTranscript(QStringLiteral("unrelated noise"));

    QVERIFY(!result.value(QStringLiteral("stable")).toBool());
    QCOMPARE(follower.position(), script.indexOf(QStringLiteral("visible")));
}

void ScriptFollowerTest::respectsTheTrackingWindow()
{
    ScriptFollower follower;
    const QString first = QStringLiteral("Alpha beta gamma delta.");
    const QString distant = QStringLiteral(" Distant orange purple telescope phrase.");
    const QString script = first + distant;
    follower.setScript(script);
    follower.setLookBackTokens(0);
    follower.setLookAheadTokens(0);
    follower.setTrackingWindow(0, first.size());

    const QVariantMap result = follower.acceptPartialTranscript(QStringLiteral("orange purple telescope"));

    QVERIFY(!result.value(QStringLiteral("stable")).toBool());
    QCOMPARE(follower.position(), 0);
}

void ScriptFollowerTest::reacquiresAfterNearbySkip()
{
    ScriptFollower follower;
    const QString script = QStringLiteral("Alpha beta gamma delta epsilon zeta eta theta.");
    follower.setScript(script);
    follower.setTrackingWindow(0, script.indexOf(QStringLiteral("delta")));

    QVERIFY(follower.acceptPartialTranscript(QStringLiteral("alpha beta")).value(QStringLiteral("stable")).toBool());
    const QVariantMap result = follower.acceptPartialTranscript(QStringLiteral("epsilon zeta eta"));

    QVERIFY(result.value(QStringLiteral("stable")).toBool());
    QCOMPARE(follower.position(), script.indexOf(QStringLiteral(" eta ")) + 1);
}

void ScriptFollowerTest::normalizesApostrophesAndCase()
{
    ScriptFollower follower;
    const QString script = QString::fromUtf8("DON\xE2\x80\x99T stop reading the visible script.");
    follower.setScript(script);
    follower.setTrackingWindow(0, script.size());

    const QVariantMap result = follower.acceptPartialTranscript(QStringLiteral("don't STOP reading"));

    QVERIFY(result.value(QStringLiteral("stable")).toBool());
    QCOMPARE(follower.position(), script.indexOf(QStringLiteral("reading")));
}

void ScriptFollowerTest::rejectsWeakBackwardMovement()
{
    ScriptFollower follower;
    const QString script = QStringLiteral("Alpha beta gamma delta epsilon zeta.");
    follower.setScript(script);
    follower.setTrackingWindow(0, script.size());

    QVERIFY(follower.acceptPartialTranscript(QStringLiteral("gamma delta epsilon")).value(QStringLiteral("stable")).toBool());
    const int trustedPosition = follower.position();
    const QVariantMap result = follower.acceptPartialTranscript(QStringLiteral("beta gamma"));

    QVERIFY(!result.value(QStringLiteral("stable")).toBool());
    QCOMPARE(follower.position(), trustedPosition);
}

QTEST_MAIN(ScriptFollowerTest)

#include "scriptfollower_test.moc"
