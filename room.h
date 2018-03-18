#pragma once

#include <QObject>
#include <QString>
#include <QDateTime>

#include "community.h"

class Event : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString sender READ getSender NOTIFY senderChanged)
    Q_PROPERTY(QString msg READ getMsg NOTIFY msgChanged)
public:
    void setSender(const QString& id) {
        sender = id;
        emit senderChanged();
    }

    void setMsg(const QString& content) {
        msg = content;
        emit msgChanged();
    }

    QString getSender() const {
        return sender;
    }

    QString getMsg() const {
        return msg;
    }

    QString eventId;
    QDateTime timestamp;
    bool sent = true;

private:
    QString sender, msg;

signals:
    void senderChanged();
    void msgChanged();
};

class Member : public QObject {
    Q_OBJECT
    Q_PROPERTY(QString id READ getId NOTIFY idChanged)
    Q_PROPERTY(QString displayName READ getDisplayName NOTIFY displayNameChanged)
    Q_PROPERTY(QString avatarURL READ getAvatar NOTIFY avatarChanged)
    Q_PROPERTY(QVariantList publicCommunities READ getPublicCommunitiesList NOTIFY publicCommunitiesChanged)
public:
    void setId(const QString& id) {
        this->id = id;
        emit idChanged();
    }

    void setDisplayName(const QString& displayName) {
        this->displayName = displayName;
        emit displayNameChanged();
    }

    void setAvatar(const QString& url) {
        avatarURL = url;
        emit avatarChanged();
    }

    void addCommunity(Community* community) {
        publicCommunities.push_back(community);
        emit publicCommunitiesChanged();
    }

    QString getId() const {
        return id;
    }

    QString getDisplayName() const {
        return displayName;
    }

    QString getAvatar() const {
        return avatarURL;
    }

    QList<Community*> getPublicCommunities() const {
        return publicCommunities;
    }

    QVariantList getPublicCommunitiesList() const {
        QVariantList list;
        for(const auto community : publicCommunities)
            list.push_back(QVariant::fromValue(community));

        return list;
    }

signals:
    void idChanged();
    void displayNameChanged();
    void avatarChanged();
    void publicCommunitiesChanged();

private:
    QString id, displayName, avatarURL;

    QList<Community*> publicCommunities;
};

class Room : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString id MEMBER id NOTIFY idChanged)
    Q_PROPERTY(QString topic MEMBER topic NOTIFY topicChanged)
    Q_PROPERTY(QString name MEMBER name NOTIFY nameChanged)
    Q_PROPERTY(QString avatar MEMBER avatar NOTIFY avatarChanged)
    Q_PROPERTY(QString joinState MEMBER joinState NOTIFY joinStateChanged)
    Q_PROPERTY(bool guestDenied MEMBER guestDenied NOTIFY guestDeniedChanged)
    Q_PROPERTY(QString invitedBy MEMBER invitedBy NOTIFY invitedByChanged)
public:
    void setId(const QString& id) {
        this->id = id;
        emit idChanged();
    }

    void setName(const QString& name) {
        this->name = name;
        emit nameChanged();
    }

    void setTopic(const QString& topic) {
        this->topic = topic;
        emit topicChanged();
    }

    void setAvatar(const QString& avatar) {
        this->avatar = avatar;
        emit avatarChanged();
    }

    void setJoinState(const QString& state) {
        joinState = state;
        emit joinStateChanged();
    }

    void setGuestDenied(const bool denied) {
        guestDenied = denied;
        emit guestDeniedChanged();
    }

    void setInvitedBy(const QString& id) {
        invitedBy = id;
        emit invitedByChanged();
    }

    QString getId() const {
        return id;
    }

    QString getName() const {
        return name;
    }

    QString getTopic() const {
        return topic;
    }

    QString getAvatar() const {
        return avatar;
    }

    QString getJoinState() const {
        return joinState;
    }

    QList<Event*> events;
    QString prevBatch;

    QList<Member*> members;

    bool direct = false;

private:
    QString id, name, topic, avatar;
    QString joinState;
    bool guestDenied = false;
    QString invitedBy;

signals:
    void idChanged();
    void topicChanged();
    void nameChanged();
    void avatarChanged();
    void joinStateChanged();
    void guestDeniedChanged();
    void invitedByChanged();
};
