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
 ** GNU General Public License for more details
 **
 ** You should have received a copy of the GNU General Public License
 ** along with this program.  If not, see <http://www.gnu.org/licenses/>.
 **
 ****************************************************************************/

#ifndef PROMPTSESSION_H
#define PROMPTSESSION_H

#include <QAbstractListModel>

struct DataPoint {
    Q_GADGET
    public:
        // Constructors
        DataPoint() {}
        //DataPoint(std::nullptr_t) {}
        DataPoint(const int time, const double position, const int prompterWidth, const int lineWidth, const int lineHeight)
            : time(time), position(position), prompterWidth(prompterWidth), lineWidth(lineWidth), lineHeight(lineHeight) {}
        // Contents
        int time = 0;
        double position = 0;
        int prompterWidth;
        int lineWidth;
        int lineHeight;
};
Q_DECLARE_METATYPE(DataPoint)

class SessionModel : public QAbstractListModel
{
    Q_OBJECT

public:
    enum Roles {
        TimeRole,
        PositionRole = Qt::UserRole,
        PrompterWidthRole,
        LineWidthRole,
        LineHeightRole
    };

    explicit SessionModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    // int columnCount(const QModelIndex &parent = QModelIndex()) const override;

    QVariant data(const QModelIndex& index, int role = Qt::DisplayRole) const override;

    QHash<int, QByteArray> roleNames() const override;

    bool dirty;

public slots:
//     void insertRow(int row, const QModelIndex &parent);
    void clearDataPoints();
    void appendDataPoint(DataPoint &data);


private slots:
    void resetInternalData();

private:
    QList <DataPoint> m_data;
};


// class Telemetry : public QObject
// {
// Q_OBJECT
// };

#endif // PROMPTSESSION_H
