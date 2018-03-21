#pragma once

#include <QObject>
#include <QString>
#include <QDebug>

class Community : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString id READ getId NOTIFY idChanged)
    Q_PROPERTY(QString name READ getName NOTIFY nameChanged)
    Q_PROPERTY(QString avatar READ getAvatar NOTIFY avatarChanged)
    Q_PROPERTY(QString shortDescription READ getShortDescription NOTIFY shortDescriptionChanged)
    Q_PROPERTY(QString longDescription READ getLongDescription NOTIFY longDescriptionChanged)
    Q_PROPERTY(QString joinState READ getJoinState NOTIFY joinStateChanged)
public:
    Community(QObject* parent = nullptr) : QObject(parent) {}

    void setId(const QString& id) {
        this->id = id;
        emit idChanged();
    }

    void setName(const QString& name) {
        this->name = name;
        emit nameChanged();
    }

    void setAvatar(const QString& url) {
        avatarURL = url;
        emit avatarChanged();
    }

    void setShortDescription(const QString& description) {
        shortDescription = description;
        emit shortDescriptionChanged();
    }

    void setLongDescription(const QString& description) {
        longDescription = description;
        emit longDescriptionChanged();
    }

    void setJoinState(const QString& state) {
        joinState = state;
        emit joinStateChanged();
    }

    QString getId() const {
        return id;
    }

    QString getName() const {
        return name;
    }

    QString getAvatar() const {
        return avatarURL;
    }

    QString getShortDescription() const {
        return shortDescription;
    }

    QString getLongDescription() const {
        return longDescription;
    }

    QString getJoinState() const {
        return joinState;
    }

signals:
    void idChanged();
    void nameChanged();
    void avatarChanged();
    void shortDescriptionChanged();
    void longDescriptionChanged();
    void joinStateChanged();

private:
    QString id, name, avatarURL, shortDescription, longDescription, joinState;
};
