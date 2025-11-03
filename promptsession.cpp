/****************************************************************************
 **
 ** QPrompt
 ** Copyright (C) 2021 Javier O. Cordero Pérez
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

#include "promptsession.h"

// #include <QDebug>
SessionModel::SessionModel(QObject *parent)
    : QAbstractListModel(parent)
{
}

int SessionModel::rowCount(const QModelIndex &parent) const
{
    if (!parent.isValid())
        return m_data.size();
        //return 0;
    return m_data.size();
}

QVariant SessionModel::data(const QModelIndex &index, int role) const
{
    if ( !index.isValid() )
        return QVariant();

    const DataPoint &data = m_data.at(index.row());
    if ( role == TimeRole )
        return data.time;
    else if ( role == PositionRole )
        return data.position;
    else if ( role == PrompterWidthRole )
        return data.prompterWidth;
    else if ( role == LineWidthRole )
        return data.lineWidth;
    else if ( role == LineHeightRole )
        return data.lineHeight;
    else
        return QVariant();
}

// Map QML property names to Model Roles
QHash<int, QByteArray> SessionModel::roleNames() const
{
    static QHash<int, QByteArray> mapping {
        {TimeRole, "time"},
        {PositionRole, "position"},
        {PrompterWidthRole, "prompterWidth"},
        {LineWidthRole, "lineWidth"},
        {LineHeightRole, "lineHeight"}
    };
    return mapping;
}

void SessionModel::resetInternalData()
{
    this->m_data.clear();
}

// void SessionModel::insertRow(int row, const QModelIndex &parent)
// {}

void SessionModel::clearDataPoints()
{
    beginRemoveRows(QModelIndex(), 0, rowCount());
    this->resetInternalData();
    endRemoveRows();
}

void SessionModel::appendDataPoint(DataPoint &data)
{
    const int listPosition = m_data.size();
    beginInsertRows(QModelIndex(), listPosition, listPosition);
    m_data.append(data);
    endInsertRows();
}

// Telemetry::Telemetry(QObject *parent)
//     : QObject(parent)
// {
// }
