#include "roomlistsortmodel.h"

#include "room.h"
#include "roomlistmodel.h"

bool RoomListSortModel::lessThan(const QModelIndex& left, const QModelIndex& right) const {
    const QString sectionLeft = sourceModel()->data(left, RoomListModel::SectionRole).toString();
    const QString sectionRight = sourceModel()->data(right, RoomListModel::SectionRole).toString();

    if(sectionRight == "Direct Chats")
        return false;

    if(sectionLeft == "Direct Chats")
        return true;

    return false;
}
