#ifndef MARKERSMODEL_H
#define MARKERSMODEL_H

#include <QAbstractListModel>

struct Data {
    Data() {}
    Data( const int lineNo, const double linePos, const QString& lineName)
        : lineNo(lineNo), linePos(linePos), lineName(lineName) {}
    int lineNo;
    double linePos;
    QString lineName;
};

class MarkersModel : public QAbstractListModel
{
    Q_OBJECT

public:
    enum Roles {
        LineNoRole = Qt::UserRole,
        LinePosRole,
        LineNameRole
    };

    explicit MarkersModel(QObject *parent = nullptr);

    // Header:
    // QVariant headerData(int section, Qt::Orientation orientation, int role = Qt::DisplayRole) const override;

    // Basic functionality:
    //QModelIndex index(int row, int column,
    //                  const QModelIndex &parent = QModelIndex()) const override;
    //QModelIndex parent(const QModelIndex &index) const override;

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    // int columnCount(const QModelIndex &parent = QModelIndex()) const override;

    QVariant data(const QModelIndex& index, int role = Qt::DisplayRole) const override;

    QHash<int, QByteArray> roleNames() const override;

public slots:
    void removeData(int row);
//     void updateData(int row);

private:
    QVector <Data> m_data;
};

#endif // MARKERSMODEL_H
