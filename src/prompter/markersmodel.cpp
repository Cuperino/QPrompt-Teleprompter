#include "markersmodel.h"

MarkersModel::MarkersModel(QObject *parent)
    : QAbstractListModel(parent)
{
    m_data
       // id, line, position, name
       << Data { 2, 2*64, "Depeche Mode" }
       << Data { 6, 6*64, "Apocalyptica" }
       << Data { 8, 8*64, "The Wachowskis" }
       << Data { 9, 9*64, "Sacha Goedegebure" };
}

// QVariant MarkersModel::headerData(int section, Qt::Orientation orientation, int role) const
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
    if (!parent.isValid())
        return 0;

    return m_data.count();
}

QVariant MarkersModel::data(const QModelIndex &index, int role) const
{
    if ( !index.isValid() )
        return QVariant();

    const Data &data = m_data.at(index.row());
    if ( role == LineNoRole )
        return data.lineNo;
    else if ( role == LinePosRole )
        return data.linePos;
    else if ( role == LineNameRole )
        return data.lineName;
    else
        return QVariant();
}

QHash<int, QByteArray> MarkersModel::roleNames() const
{
    static QHash<int, QByteArray> mapping {
        {LineNoRole, "lineNo"},
        {LinePosRole, "linePos"},
        {LineNameRole, "lineName"}
    };
    return mapping;
}

void MarkersModel::removeData(int row)
{
    if (row < 0 || row>=m_data.count())
        return;

    beginRemoveRows(QModelIndex(), row, row);
    m_data.removeAt(row);
    endRemoveRows();
}
