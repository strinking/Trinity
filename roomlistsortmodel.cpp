#include "roomlistsortmodel.h"

#include "room.h"
#include "roomlistmodel.h"

bool RoomListSortModel::lessThan(const QModelIndex& left, const QModelIndex& right) const {
    const QString joinStateLeft = sourceModel()->data(left, RoomListModel::JoinStateRole).toString();
    const QString joinStateRight = sourceModel()->data(right, RoomListModel::JoinStateRole).toString();

    if(joinStateLeft == "invite")
        return false;

    return true;
}
