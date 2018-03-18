#pragma once

#include <QAbstractListModel>

class Room;

class RoomListModel : public QAbstractListModel
{
    Q_OBJECT
public:
    enum EventRoles {
        AliasRole = Qt::UserRole + 1,
        AvatarRole,
        JoinStateRole,
        TopicRole,
        IdRole,
        HighlightCountRole,
        NotificationCountRole
    };

    RoomListModel(QList<Room*>& rooms);

    int rowCount(const QModelIndex &parent) const override;

    QVariant data(const QModelIndex &index, int role) const override;

    void beginInsertRoom() {
        beginInsertRows(QModelIndex(), rooms.size(), rooms.size());
    }

    void endInsertRoom() {
        endInsertRows();
    }

    void fullUpdate() {
        emit layoutChanged();
    }

    void updateRoom(Room* room);

protected:
    QList<Room*>& rooms;
    QHash<int, QByteArray> roleNames() const override;
};
