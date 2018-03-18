#pragma once

#include <QSortFilterProxyModel>

class RoomListSortModel : public QSortFilterProxyModel
{
    Q_OBJECT
public:
    bool lessThan(const QModelIndex &source_left, const QModelIndex &source_right) const;
};

