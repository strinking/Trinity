#pragma once

#include <QObject>
#include <QString>
#include <QDateTime>
#include <QSettings>

#include "community.h"

class Event : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString sender READ getSender NOTIFY senderChanged)
    Q_PROPERTY(QString msg READ getMsg NOTIFY msgChanged)
public:
    Event(QObject* parent = nullptr) : QObject(parent) {}

    void setSender(const QString& id) {
        sender = id;
        emit senderChanged();
    }

    void setMsg(const QString& content) {
        msg = content;
        emit msgChanged();
    }

    void setRoom(const QString& room) {
        this->room = room;
    }

    QString getSender() const {
        return sender;
    }

    QString getMsg() const {
        return msg;
    }

    QString getRoom() const {
        return room;
    }

    QString eventId;
    QDateTime timestamp;
    bool sent = true;

private:
    QString sender, msg;
    QString room;

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
    Member(QObject* parent = nullptr) : QObject(parent) {}

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
    Q_PROPERTY(QString name READ getName NOTIFY nameChanged)
    Q_PROPERTY(QString avatar MEMBER avatar NOTIFY avatarChanged)
    Q_PROPERTY(QString joinState MEMBER joinState NOTIFY joinStateChanged)
    Q_PROPERTY(bool guestDenied MEMBER guestDenied NOTIFY guestDeniedChanged)
    Q_PROPERTY(QString invitedBy MEMBER invitedBy NOTIFY invitedByChanged)
    Q_PROPERTY(QString highlightCount READ getHighlightCount NOTIFY highlightCountChanged)
    Q_PROPERTY(QString notificationCount READ getNotificationCount NOTIFY notificationCountChanged)
    Q_PROPERTY(bool direct READ getDirect NOTIFY directChanged)
    Q_PROPERTY(int notificationLevel READ getNotificationLevel WRITE setNotificationLevel NOTIFY notificationLevelChanged)
public:
    Room(QObject* parent = nullptr) : QObject(parent) {}

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

    void setHighlightCount(const unsigned int num) {
        highlightCount = num;
        emit highlightCountChanged();
    }

    void setNotificationCount(const unsigned int num) {
        notificationCount = num;
        emit notificationCountChanged();
    }

    void setDirect(const bool direct) {
        this->direct = direct;
        emit directChanged();
    }

    void setNotificationLevel(const int level, const bool skipSave = false) {
        notificationLevel = level;

        if(!skipSave) {
            QSettings settings;
            settings.beginGroup(id);
            settings.setValue("notificationLevel", notificationLevel);
            settings.endGroup();
        }

        emit notificationLevelChanged();
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

    unsigned int getHighlightCount() const {
        return highlightCount;
    }

    unsigned int getNotificationCount() const {
        return notificationCount;
    }

    bool getDirect() const {
        return direct;
    }

    int getNotificationLevel() const {
        return notificationLevel;
    }

    QList<Event*> events;
    QString prevBatch;

    QList<Member*> members;

private:
    QString id, name, topic, avatar;
    QString joinState;
    bool guestDenied = false;
    QString invitedBy;
    unsigned int highlightCount = 0, notificationCount = 0;
    bool direct = false;
    int notificationLevel = 1;

signals:
    void idChanged();
    void topicChanged();
    void nameChanged();
    void avatarChanged();
    void joinStateChanged();
    void guestDeniedChanged();
    void invitedByChanged();
    void highlightCountChanged();
    void notificationCountChanged();
    void directChanged();
    void notificationLevelChanged();
};