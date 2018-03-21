#pragma once

#include <QAbstractListModel>
#include <QDebug>

class Community;

class CommunityListModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(QVariantList communities WRITE setCommunities)
public:
    int rowCount(const QModelIndex &parent) const override;

    QVariant data(const QModelIndex &index, int role) const override;

    void setCommunities(const QVariantList& list) {
        communities.clear();

        for(const auto& value : list)
            communities.push_back(qvariant_cast<Community*>(value));

        emit layoutChanged();
    }

protected:
    QList<Community*> communities;
};
