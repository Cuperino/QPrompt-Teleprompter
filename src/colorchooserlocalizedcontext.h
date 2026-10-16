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

#pragma once

#include <QObject>
#include <QString>
#include <QVariant>

/*
 * KColorChooser's QML calls KI18n's i18n(), which QPrompt does not link.
 * Installed as the root context object, this resolves those calls through
 * Qt's translation system instead, under the "KColorChooser" context.
 */
class ColorChooserLocalizedContext : public QObject
{
    Q_OBJECT

public:
    using QObject::QObject;

    Q_INVOKABLE QString i18n(const QString &text, const QVariant &arg1 = QVariant()) const;
};
