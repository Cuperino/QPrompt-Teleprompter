/****************************************************************************
 **
 ** QPrompt
 ** Copyright (C) 2021 Javier O. Cordero Pérez
 **
 ** This file is part of QPrompt.
 **
 ** This program is free software: you can redistribute it and/or modify
 ** it under the terms of the GNU General Public License as published by
 ** the Free Software Foundation, either version 3 of the License, or
 ** (at your option) any later version.
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

#include "markersmodel.h"

#include <QDebug>

MarkersModel::MarkersModel(QObject *parent)
    : QAbstractListModel(parent)
{
//  Test data: names, position, text
//     m_data
//        << Marker { QStringList("1"), 2*64, "Depeche Mode" }
//        << Marker { QStringList("2"), 6*64, "Apocalyptica" }
//        << Marker { QStringList("4"), 8*64, "The Wachowskis" }
//        << Marker { QStringList("a"), 9*64, "Sacha Goedegebure" };
}

// QVariant MarkersModel::headerMarker(int section, Qt::Orientation orientation, int role) const
// {
//     //FIXME: Implement me!
// }
// 
// QModelIndex MarkersModel::index(int row, int column, const QModelIndex &parent) const
// {
//     //FIXME: Implement me!
// }
// 
// QModelIndex MarkersModel::parent(const QModelIndex &index) const
// {
//     //FIXME: Implement me!
// }

int MarkersModel::rowCount(const QModelIndex &parent) const
{
//     if (!parent.isValid())
//         return 0;

    return m_data.size();
}

QVariant MarkersModel::data(const QModelIndex &index, int role) const
{
    if ( !index.isValid() )
        return QVariant();

    const Marker &data = m_data.at(index.row());
    if ( role == NamesRole )
        return data.names;
    else if ( role == PositionRole )
        return data.position;
    else if ( role == TextRole )
        return data.text;
    else
        return QVariant();
}

// Map QML property names to Model Roles
QHash<int, QByteArray> MarkersModel::roleNames() const
{
    static QHash<int, QByteArray> mapping {
        {NamesRole, "names"},
        {PositionRole, "position"},
        {TextRole, "text"}
    };
    return mapping;
}

void MarkersModel::resetInternalData()
{
    this->m_data.clear();
}

void MarkersModel::removeMarker(int row)
{
    if (row < 0 || row>=m_data.count())
        return;

    beginRemoveRows(QModelIndex(), row, row);
    m_data.removeAt(row);
    endRemoveRows();
}

// void MarkersModel::insertRow(int row, const QModelIndex &parent)
// {}

void MarkersModel::clearMarkers()
{
    beginRemoveRows(QModelIndex(), 0, rowCount());
    this->resetInternalData();
    endRemoveRows();
}

void MarkersModel::appendMarker(Marker &marker)
{
    const int listPosition = m_data.size();
    beginInsertRows(QModelIndex(), listPosition, listPosition);
    m_data.append(marker);
    endInsertRows();
}
