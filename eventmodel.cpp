#include "eventmodel.h"

#include <QDebug>

#include "room.h"
#include "matrixcore.h"

EventModel::EventModel(MatrixCore& matrix) : matrix(matrix) {}

int EventModel::rowCount(const QModelIndex &parent) const {
    if(!room)
        return 0;

    return room->events.size();
}

QVariant EventModel::data(const QModelIndex &index, int role) const {
    if(!room || index.row() >= room->events.size())
        return "";

    const Event* event = room->events[index.row()];

    if(role == SenderRole) {
        const Member* member = matrix.resolveMemberId(event->getSender());
        return member ? member->getDisplayName() : "Unknown";
    } else if(role == MsgRole) {
        return event->getMsg();
    } else if(role == SentRole) {
        return event->sent;
    } else if(role == TimestampRole) {
        return event->timestamp.toString(Qt::DefaultLocaleShortDate);
    } else if(role == AvatarURLRole) {
        const Member* member = matrix.resolveMemberId(event->getSender());
        if(member)
            return member->getAvatar();
    } else if(role == EventIdRole) {
        return event->eventId;
    } else if(role == SenderIdRole) {
        return event->getSender();
    } else if(role == CondenseRole) {
        if(index.row() + 1 >= room->events.size())
            return false;

        const Event* previousEvent = room->events[index.row() + 1];
        return previousEvent->getSender() == event->getSender();
    }

    return "";
}

QHash<int, QByteArray> EventModel::roleNames() const {
    QHash<int, QByteArray> roles;
    roles[SenderRole] = "sender";
    roles[MsgRole] = "msg";
    roles[SentRole] = "sent";
    roles[TimestampRole] = "timestamp";
    roles[AvatarURLRole] = "avatarURL";
    roles[EventIdRole] = "eventId";
    roles[SenderIdRole] = "senderId";
    roles[CondenseRole] = "condense";

    return roles;
}

void EventModel::setRoom(Room* room) {
    this->room = room;
}

void EventModel::beginUpdate(const unsigned int num) {
    if(room)
        beginInsertRows(QModelIndex(), 0, num);
}

void EventModel::beginHistory(int size) {
    beginInsertRows(QModelIndex(), room->events.size(), room->events.size() + size);
}

void EventModel::updateEvent(const Event* event) {
    for(size_t i = 0; i < room->events.size(); i++) {
        if(room->events[i] == event) {
            emit dataChanged(createIndex(i, 0), createIndex(i, 0));
            return;
        }
    }
}
