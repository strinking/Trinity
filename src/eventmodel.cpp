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

    Event* event = room->events[index.row()];

    if(role == Qt::DisplayRole) {
        return QVariant::fromValue<Event*>(event);
    } else if(role == CondenseRole) {
        if(index.row() + 1 >= room->events.size())
            return false;

        const Event* previousEvent = room->events[index.row() + 1];
        return previousEvent->getSender() == event->getSender();
    } else if(role == TimestampRole)
        return event->timestamp.toString(Qt::DefaultLocaleShortDate);

    return "";
}

QHash<int, QByteArray> EventModel::roleNames() const {
    QHash<int, QByteArray> roles;
    roles[Qt::DisplayRole] = "display";
    roles[CondenseRole] = "condense";
    roles[TimestampRole] = "timestamp";

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
    if(room)
        beginInsertRows(QModelIndex(), room->events.size(), room->events.size() + size);
}

void EventModel::updateEvent(const Event* event) {
    if(!room)
        return;

    for(size_t i = 0; i < room->events.size(); i++) {
        if(room->events[i] == event) {
            emit dataChanged(createIndex(i, 0), createIndex(i, 0));
            return;
        }
    }
}

void EventModel::updateEventsByMember(const QString& id) {
    if(!room)
        return;

    for(size_t i = 0; i < room->events.size(); i++) {
        if(room->events[i]->getSender() == id)
            emit dataChanged(createIndex(i, 0), createIndex(i, 0));
    }
}
