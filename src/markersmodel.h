/****************************************************************************
 **
 ** QPrompt
 ** Copyright (C) 2021-2022 Javier O. Cordero Pérez
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
 ** GNU General Public License for more details
 **
 ** You should have received a copy of the GNU General Public License
 ** along with this program.  If not, see <http://www.gnu.org/licenses/>.
 **
 ****************************************************************************/

#ifndef MARKERSMODEL_H
#define MARKERSMODEL_H

#include <QAbstractListModel>
#include <QObject>
#include <QQmlEngine>

#include "marker.hpp"

class MarkersModel : public QAbstractListModel
{
    Q_OBJECT
    QML_ELEMENT

public:
    enum Roles { TextRole = Qt::UserRole, PositionRole, LengthRole, KeyRole, KeyLetterRole, UrlRole, RequestTypeRole };

    explicit MarkersModel(QObject *parent = nullptr);

    // Header:
    // QVariant headerMarker(int section, Qt::Orientation orientation, int role = Qt::DisplayRole) const override;

    // Basic functionality:
    // QModelIndex index(int row, int column,
    //                  const QModelIndex &parent = QModelIndex()) const override;
    // QModelIndex parent(const QModelIndex &index) const override;

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    // int columnCount(const QModelIndex &parent = QModelIndex()) const override;

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;

    QHash<int, QByteArray> roleNames() const override;

    bool dirty;

    // Q_SIGNALS:
    // void insertRow(int row, const QModelIndex &parent);
    void clearMarkers();
    void appendMarker(const Marker &marker);
    void removeMarker(int row);
    Marker previousMarker(int position);
    Marker nextMarker(int position);
    int keySearch(int key, int currentPosition, bool reverse, bool wrap);

    // void updateMarker(int row);

private:
    QList<Marker> m_data;

private Q_SLOTS:
#if QT_VERSION >= QT_VERSION_CHECK(6, 0, 0)
    void resetInternalData() override;
#else
    void resetInternalData();
#endif
    Marker binarySearch(const int lo, const int hi, const int x, const bool reverse);
};

#endif // MARKERSMODEL_H
