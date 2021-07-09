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

#include <bits/stdc++.h>
#include <QDebug>

// using namespace std;

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

// Key based circular search
int MarkersModel::keySearch(QString key, int currentPosition=0, bool reverse=false, bool wrap=true) {
    // Assuming QModelIndex is at start position.
    QModelIndexList markersThatMatchShortcut = this->match(index(0), MarkersModel::NamesRole, key, 1, Qt::MatchFlags(Qt::MatchStartsWith|Qt::MatchWrap));
    const int size = markersThatMatchShortcut.size();
    if (size) {
        if (reverse) {
            int previousPosition = size;
            for (int i=previousPosition-1; i>-1; i--) {
                const int nextPosition = data(markersThatMatchShortcut[i], MarkersModel::PositionRole).toInt();
                if (currentPosition>nextPosition)
                    return nextPosition;
                previousPosition = nextPosition;
            }
            // if already reached first, go to last
            if (wrap)
                return data(markersThatMatchShortcut[size-1], MarkersModel::PositionRole).toInt();
        }
        else {
            int previousPosition = 0;
            for (int i=0; i<size; i++) {
                const int nextPosition = data(markersThatMatchShortcut[i], MarkersModel::PositionRole).toInt();
                if (currentPosition<nextPosition)
                    return nextPosition;
                previousPosition = nextPosition;
            }
            // if already reached last, go to first
            if (wrap)
                return data(markersThatMatchShortcut[0], MarkersModel::PositionRole).toInt();
        }
    }
    return -1;
}

int MarkersModel::binarySearch(int l, int r, int goalPosition, bool reverse=false) {
    // If x is present in arr[0..n-1], then returns
    // index of it, else returns -1.
    qDebug() << "search in progress";
    int mid;

    // Since array is sorted, an element present
    // in array must be in range defined by corner
    if (r>=l) {
        qDebug() << "l: " << l << ", r: " << r << ", gp: " << goalPosition;

        // Binary search
        mid = l + (r - l) / 2;
        // Interpolation search
        // Probing the position while keeping uniform distribution in mind
        // is current start displacement times percentage displacement with a likelihood of approximation
//         pos = lo
//         + (((double)(hi - lo) / (highPosition - lowPosition))
//         * (goalPosition - lowPosition));
//         qDebug() << "pos: " << mid;

        const int aimValue = m_data.at(mid).position;
//         qDebug() << "aimPos: " << aimPosition;
        // Condition of target found
        if (aimValue == goalPosition) {
            // Dev: Add if not reverse
            qDebug() << "unts";
            if (mid==rowCount()-1) {
                qDebug() << "mid equals";
                return m_data.at(mid).position;
            }
            else {
                qDebug() << "mid not equals:" << mid << rowCount();
                if (reverse) {
                    if (mid-1>=0)
                        return m_data.at(mid-1).position;
                    return m_data.at(mid).position;
                }
                else
                    return m_data.at(mid+1).position;
            }
        }
        // If x is smaller, x is in left sub array
        if (aimValue > goalPosition)
            return binarySearch(l, mid - 1, goalPosition, reverse);
        // If x is larger, x is in right sub array
        if (mid!=rowCount()-1)
            return binarySearch(mid + 1, r, goalPosition, reverse);
    }
    qDebug() << "Final l: " << l << ", r: " << r << ", gp: " << goalPosition << ", rows: " << rowCount();
    if (reverse) {
        if (l-1>=0)
            return m_data.at(l-1).position;
        return m_data.at(l).position;
    }
    else
        return m_data.at(l).position;
}

int MarkersModel::nextMarker(int position) {
    return this->binarySearch(0, rowCount()-1, position, false);
}

int MarkersModel::previousMarker(int position) {
    return this->binarySearch(0, rowCount()-1, position, true);
}
