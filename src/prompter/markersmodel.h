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
 ** GNU General Public License for more details
 **
 ** You should have received a copy of the GNU General Public License
 ** along with this program.  If not, see <http://www.gnu.org/licenses/>.
 **
 ****************************************************************************/

#ifndef MarkerSMODEL_H
#define MarkerSMODEL_H

#include <QAbstractListModel>

struct Marker {
    Marker() {}
    Marker(const QString& text, const double position, const int key, const QString& url, const int requestType)
        : text(text), position(position), key(key), url(url), requestType(requestType) {}
    QString text;
    double position;
    int key;
    QString url;
    int requestType;
};

class MarkersModel : public QAbstractListModel
{
    Q_OBJECT

public:
    enum Roles {
        TextRole = Qt::UserRole,
        PositionRole,
        KeyRole,
        UrlRole,
        RequestTypeRole
    };

    explicit MarkersModel(QObject *parent = nullptr);

    // Header:
    // QVariant headerMarker(int section, Qt::Orientation orientation, int role = Qt::DisplayRole) const override;

    // Basic functionality:
    //QModelIndex index(int row, int column,
    //                  const QModelIndex &parent = QModelIndex()) const override;
    //QModelIndex parent(const QModelIndex &index) const override;

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    // int columnCount(const QModelIndex &parent = QModelIndex()) const override;

    QVariant data(const QModelIndex& index, int role = Qt::DisplayRole) const override;

    QHash<int, QByteArray> roleNames() const override;

    bool dirty;

public slots:
//     void insertRow(int row, const QModelIndex &parent);
    void clearMarkers();
    void appendMarker(Marker &marker);
    void removeMarker(int row);
    int previousMarker(int position);
    int nextMarker(int position);
    int keySearch(int key, int currentPosition, bool reverse, bool wrap);

//     void updateMarker(int row);


private slots:
    void resetInternalData();
    int binarySearch(int lo, int hi, int x, bool reverse);

private:
    QList <Marker> m_data;
};

#endif // MarkerSMODEL_H
