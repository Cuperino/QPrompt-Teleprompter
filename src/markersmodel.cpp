/****************************************************************************
 **
 ** QPrompt
 ** Copyright (C) 2021-2024 Javier O. Cordero Pérez
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

#include "markersmodel.h"

// #include <QDebug>

MarkersModel::MarkersModel(QObject *parent)
    : QAbstractListModel(parent),
    dirty(false)
{
}

int MarkersModel::rowCount(const QModelIndex &parent) const
{
    if (!parent.isValid())
        return m_data.size();
    return m_data.size();
}

QVariant MarkersModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid())
        return QVariant();

    const Marker &data = m_data.at(index.row());
    if (role == TextRole)
        return data.text;
    else if (role == PositionRole)
        return data.position;
    else if (role == LengthRole)
        return data.position;
    else if (role == KeyRole)
        return data.key;
    else if (role == KeyLetterRole)
        return data.keyLetter;
    else if (role == UrlRole)
        return data.url;
    else if (role == RequestTypeRole)
        return data.requestType;
    else
        return QVariant();
}

// Map QML property names to Model Roles
QHash<int, QByteArray> MarkersModel::roleNames() const
{
    static QHash<int, QByteArray> mapping{{TextRole, "text"},
                                          {PositionRole, "position"},
                                          {LengthRole, "length"},
                                          {KeyRole, "key"},
                                          {KeyLetterRole, "keyLetter"},
                                          {UrlRole, "url"},
                                          {RequestTypeRole, "requestType"}};
    return mapping;
}

void MarkersModel::resetInternalData()
{
    this->m_data.clear();
}

void MarkersModel::removeMarker(int row)
{
    if (row < 0 || row >= m_data.count())
        return;

    beginRemoveRows(QModelIndex(), row, row);
    m_data.removeAt(row);
    endRemoveRows();
}

void MarkersModel::clearMarkers()
{
    beginRemoveRows(QModelIndex(), 0, rowCount());
    this->resetInternalData();
    endRemoveRows();
}

void MarkersModel::appendMarker(const Marker &marker)
{
    const int listPosition = m_data.size();
    beginInsertRows(QModelIndex(), listPosition, listPosition);
    m_data.append(marker);
    endInsertRows();
}

// Key based circular search
int MarkersModel::keySearch(int key, int currentPosition = 0, bool reverse = false, bool wrap = true)
{
    // Assuming QModelIndex is at start position.
    QModelIndexList markersThatMatchShortcut = this->match(index(0), MarkersModel::KeyRole, key, 1, Qt::MatchFlags(Qt::MatchStartsWith | Qt::MatchWrap));
    const int size = markersThatMatchShortcut.size();
    if (size) {
        if (reverse) {
            const int previousPosition = size;
            for (int i = previousPosition - 1; i > -1; i--) {
                const int nextPosition = data(markersThatMatchShortcut[i], MarkersModel::PositionRole).toInt();
                if (currentPosition > nextPosition)
                    return nextPosition;
                // previousPosition = nextPosition;
            }
            // if already reached first, go to last
            if (wrap)
                return data(markersThatMatchShortcut[size - 1], MarkersModel::PositionRole).toInt();
        } else {
            // int previousPosition = 0;
            for (int i = 0; i < size; i++) {
                const int nextPosition = data(markersThatMatchShortcut[i], MarkersModel::PositionRole).toInt();
                if (currentPosition < nextPosition)
                    return nextPosition;
                // previousPosition = nextPosition;
            }
            // if already reached last, go to first
            if (wrap)
                return data(markersThatMatchShortcut[0], MarkersModel::PositionRole).toInt();
        }
    }
    return -1;
}

// Custom Recursive Binary Search: Returns most proximate element in a given direction when searched element is not found.
Marker MarkersModel::binarySearch(const double l, const double r, const double goalPosition, const bool reverse = false)
{
    // qDebug() << "search in progress";
    if (r >= l) {
        // qDebug() << "l: " << l << ", r: " << r << ", gp: " << goalPosition;

        // Binary search
        const double mid = l + (r - l) / 2;

        const double aimValue = m_data.at(mid).position;
        // Base case
        if (aimValue == goalPosition) {
            // If last element
            if (mid == rowCount() - 1) {
                // qDebug() << "mid equals";
                if (reverse) {
                    if (mid == 0)
                        return Marker();
                    else
                        return m_data.at(mid - 1);
                }
                // Return last marker
                // return m_data.at(mid);
                // Return a virtual marker that goes after the last marker. This workaround ensures we can detect when the prompter moves past the last marker.
                return Marker(m_data.at(mid).position);
            }
            // If not last element
            else {
                // qDebug() << "mid not equals:" << mid << rowCount();
                if (reverse) {
                    if (mid - 1 >= 0)
                        return m_data.at(mid - 1);
                    return Marker();
                } else
                    return m_data.at(mid + 1);
            }
        }
        // If x is smaller, x is in left sub array
        if (aimValue > goalPosition)
            return binarySearch(l, mid - 1, goalPosition, reverse);
        // If x is larger, x is in right sub array
        if (mid != rowCount() - 1)
            return binarySearch(mid + 1, r, goalPosition, reverse);
    }
    // Base case continuation, when exact match is not found
    // qDebug() << "Final l: " << l << ", r: " << r << ", gp: " << goalPosition << ", rows: " << rowCount();
    if (reverse) {
        if (r < 0)
            return Marker(); // 0 // m_data.at(0).position;
        return m_data.at(r);
    } else
        return m_data.at(l);
}

Marker MarkersModel::nextMarker(double position)
{
    // qDebug() << Qt::endl;
    const int size = rowCount();
    if (size)
        // Find next marker
        return this->binarySearch(0, size - 1, position, false);
    // Stay in place
    Marker invalidPositionMarker = Marker(-1);
    return invalidPositionMarker; // -1
}

Marker MarkersModel::previousMarker(double position)
{
    // qDebug() << Qt::endl;
    const int size = rowCount();
    if (size)
        // Find previous marker
        return this->binarySearch(0, size - 1, position, true);
    // Move to start
    return Marker();
}
