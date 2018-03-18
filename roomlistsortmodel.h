#pragma once

#include <QSortFilterProxyModel>

class RoomListSortModel : public QSortFilterProxyModel
{
    Q_OBJECT
public:
    bool lessThan(const QModelIndex &source_left, const QModelIndex &source_right) const;

    Q_INVOKABLE unsigned int getOriginalIndex(const unsigned int i) const {
        auto const proxyIndex = index(i, 0);
        auto const sourceIndex = mapToSource(proxyIndex);

        return sourceIndex.row();
    }
};

