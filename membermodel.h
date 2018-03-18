#pragma once

#include <QAbstractListModel>

class Room;

class MemberModel : public QAbstractListModel
{
    Q_OBJECT
public:
    enum EventRoles {
        DisplayNameRole = Qt::UserRole + 1,
        AvatarURLRole,
        IdRole
    };

    int rowCount(const QModelIndex &parent) const override;

    QVariant data(const QModelIndex &index, int role) const override;

    void beginUpdate(const unsigned int num) {
        beginInsertRows(QModelIndex(), 0, num);
    }

    void endUpdate() {
        endInsertRows();
    }

    void setRoom(Room* room) {
        this->room = room;
    }

    void fullUpdate() {
        emit layoutChanged();
    }

protected:
    Room* room = nullptr;
    QHash<int, QByteArray> roleNames() const override;
};
