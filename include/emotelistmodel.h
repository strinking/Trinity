#pragma once

#include <QAbstractListModel>
#include <QDebug>

#include "emote.h"

class EmoteListModel : public QAbstractListModel
{
    Q_OBJECT
public:
    int rowCount(const QModelIndex &parent) const override;

    QVariant data(const QModelIndex &index, int role) const override;

    void setList(QList<Emote*>* emotes) {
        this->emotes = emotes;
        emit layoutChanged();
    }

    void update() {
        emit layoutChanged();
    }

protected:
    QList<Emote*>* emotes = nullptr;
};
