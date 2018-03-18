#include "roomlistmodel.h"

#include "room.h"

RoomListModel::RoomListModel(QList<Room*>& rooms) : rooms(rooms) {}

int RoomListModel::rowCount(const QModelIndex &parent) const {
    return rooms.size();
}

QVariant RoomListModel::data(const QModelIndex &index, int role) const {
    if(role == AliasRole)
        return rooms[index.row()]->getName();
    else if(role == AvatarRole)
        return rooms[index.row()]->getAvatar();
    else if(role == JoinStateRole)
        return rooms[index.row()]->getJoinState();
    else if(role == TopicRole)
        return rooms[index.row()]->getTopic();
    else if(role == IdRole)
        return rooms[index.row()]->getId();
    else if(role == HighlightCountRole)
        return rooms[index.row()]->getHighlightCount();
    else if(role == NotificationCountRole)
        return rooms[index.row()]->getNotificationCount();
    else if(role == DirectRole)
        return rooms[index.row()]->direct;
    else {
        if(rooms[index.row()]->direct)
            return "Direct Chats";
        else
            return rooms[index.row()]->getJoinState();
    }
}

QHash<int, QByteArray> RoomListModel::roleNames() const {
    QHash<int, QByteArray> roles;
    roles[AliasRole] = "alias";
    roles[AvatarRole] = "avatarURL";
    roles[JoinStateRole] = "joinState";
    roles[TopicRole] = "topic";
    roles[IdRole] = "id";
    roles[HighlightCountRole] = "highlightCount";
    roles[NotificationCountRole] = "notificationCount";
    roles[DirectRole] = "direct";
    roles[SectionRole] = "section";

    return roles;
}

void RoomListModel::updateRoom(Room *room) {
    for(unsigned i = 0; i < rooms.size(); i++) {
        if(room == rooms[i])
            emit dataChanged(createIndex(i, 0), createIndex(i, 0));
    }
}
