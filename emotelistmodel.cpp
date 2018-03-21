#include "emotelistmodel.h"

int EmoteListModel::rowCount(const QModelIndex &parent) const {
    return emotes->size();
}

QVariant EmoteListModel::data(const QModelIndex &index, int role) const {
    if (role == Qt::DisplayRole)
        return QVariant::fromValue<Emote*>(emotes->at(index.row()));

    return QVariant();
}
