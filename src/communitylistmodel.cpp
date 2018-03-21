#include "communitylistmodel.h"

#include "community.h"

int CommunityListModel::rowCount(const QModelIndex &parent) const {
    return communities.size();
}

QVariant CommunityListModel::data(const QModelIndex &index, int role) const {
    if (role == Qt::DisplayRole)
        return QVariant::fromValue<Community*>(communities.at(index.row()));

    return QVariant();
}
