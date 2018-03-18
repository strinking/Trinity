#include "membermodel.h"

#include "room.h"

int MemberModel::rowCount(const QModelIndex &parent) const {
    if(!room)
        return 0;

    return room->members.size();
}

QVariant MemberModel::data(const QModelIndex &index, int role) const {
    if(!room)
        return "";

    if(index.row() >= room->members.size())
        return "";

    if(role == DisplayNameRole)
        return room->members.at(index.row())->getDisplayName();
    else if(role == AvatarURLRole)
        return room->members.at(index.row())->getAvatar();
    else
        return room->members.at(index.row())->getId();
}

QHash<int, QByteArray> MemberModel::roleNames() const {
    QHash<int, QByteArray> roles;
    roles[DisplayNameRole] = "displayName";
    roles[AvatarURLRole] = "avatarURL";
    roles[IdRole] = "id";

    return roles;
}
