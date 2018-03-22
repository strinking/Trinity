#pragma once

#include <QObject>
#include <QList>
#include <QMap>
#include <QJsonObject>

#include "eventmodel.h"
#include "room.h"
#include "roomlistmodel.h"
#include "membermodel.h"
#include "roomlistsortmodel.h"
#include "emote.h"
#include "emotelistmodel.h"

class MatrixCore : public QObject
{
    Q_OBJECT
    Q_PROPERTY(EventModel* eventModel READ getEventModel NOTIFY currentRoomChanged)
    Q_PROPERTY(RoomListSortModel* roomListModel READ getRoomListModel NOTIFY roomListChanged)
    Q_PROPERTY(Room* currentRoom READ getCurrentRoom NOTIFY currentRoomChanged)
    Q_PROPERTY(QList<Room*> rooms MEMBER rooms NOTIFY roomListChanged)
    Q_PROPERTY(QString homeserverURL READ getHomeserverURL NOTIFY homeserverChanged)
    Q_PROPERTY(MemberModel* memberModel READ getMemberModel NOTIFY currentRoomChanged)
    Q_PROPERTY(QString displayName READ getDisplayName NOTIFY displayNameChanged)
    Q_PROPERTY(QVariantList joinedCommunities READ getJoinedCommunitiesList NOTIFY joinedCommunitiesChanged)
    Q_PROPERTY(RoomListSortModel* publicRooms READ getDirectoryListModel NOTIFY publicRoomsChanged)
    Q_PROPERTY(QString typingText READ getTypingText NOTIFY typingTextChanged)
    Q_PROPERTY(bool markdownEnabled READ getMarkdownEnabled WRITE setMarkdownEnabled NOTIFY markdownEnabledChanged)
    Q_PROPERTY(EmoteListModel* localEmoteModel READ getLocalEmoteListModel NOTIFY localEmotesChanged)
public:
    MatrixCore(QObject* parent = nullptr);

    // account
    Q_INVOKABLE void registerAccount(const QString& username, const QString& password, const QString& session = "", const QString& type = "");

    Q_INVOKABLE void login(const QString& username, const QString& password);
    Q_INVOKABLE void logout();

    Q_INVOKABLE void updateAccountInformation();
    Q_INVOKABLE void setDisplayName(const QString& name);

    // sync
    Q_INVOKABLE void sync();

    // messaging
    Q_INVOKABLE void sendMessage(Room* room, const QString& message);
    Q_INVOKABLE void removeMessage(const QString& eventId);

    Q_INVOKABLE void startDirectChat(const QString& id);

    Q_INVOKABLE void setTyping(Room* room);

    // room
    Q_INVOKABLE void joinRoom(const QString& id);
    Q_INVOKABLE void leaveRoom(const QString& id);
    Q_INVOKABLE void inviteToRoom(Room* room, const QString& userId);

    Q_INVOKABLE void updateMembers(Room* room);
    Q_INVOKABLE void readMessageHistory(Room* room);

    // member
    Q_INVOKABLE void updateMemberCommunities(Member* member);

    // client related
    Q_INVOKABLE bool settingsValid();

    Q_INVOKABLE void setHomeserver(const QString& url);

    Q_INVOKABLE void changeCurrentRoom(Room* room);
    Q_INVOKABLE void changeCurrentRoom(const unsigned int index);

    Q_INVOKABLE void addEmote(const QString& url);
    Q_INVOKABLE void deleteEmote(Emote* emote);

    Q_INVOKABLE Member* resolveMemberId(const QString& id) const;
    Q_INVOKABLE Community* resolveCommunityId(const QString& id) const;
    Q_INVOKABLE Room* resolveRoomId(const QString& id) const;

    Q_INVOKABLE Room* getRoom(const unsigned int index) const;

    Q_INVOKABLE QString getUsername() const;

    Q_INVOKABLE void loadDirectory();

    Q_INVOKABLE void readUpTo(Room* room, const int index);

    void setMarkdownEnabled(const bool enabled);

    Room* getCurrentRoom();

    EventModel* getEventModel();
    RoomListSortModel* getRoomListModel();
    RoomListSortModel* getDirectoryListModel();
    MemberModel* getMemberModel();
    EmoteListModel* getLocalEmoteListModel();

    QString getHomeserverURL() const;

    QVariantList getJoinedCommunitiesList() const;

    QString getTypingText() const;

    bool getMarkdownEnabled() const;

    EventModel eventModel;
    RoomListModel roomListModel, directoryListModel;
    RoomListSortModel roomListSortModel, directoryListSortModel;
    MemberModel memberModel;
    EmoteListModel localEmoteModel;

    Room* currentRoom = nullptr;

signals:
    void registerAttempt(bool error, QString description);
    void registerFlow(QJsonObject data);
    void loginAttempt(bool error, QString description);
    void syncFinished();
    void initialSyncFinished();
    void currentRoomChanged();
    void roomListChanged();
    void message(Room* room, QString sender, QString content);
    void homeserverChanged(bool valid, QString description);
    void displayNameChanged();
    void joinedCommunitiesChanged();
    void publicRoomsChanged();
    void typingTextChanged();
    void markdownEnabledChanged();
    void localEmotesChanged();

private:
    void consumeEvent(const QJsonObject& event, Room& room, const bool insertFront = true);
    Community* createCommunity(const QString& id);

    QString getMXCThumbnailURL(QString url);
    QString getMXCMediaURL(QString url);

    QString getDisplayName() const;

    QList<Room*> rooms;
    Room emptyRoom;

    QString nextBatch, homeserverURL, userId, displayName;

    QList<QString> invitedRooms, joinedRooms;
    QList<Room*> publicRooms;

    QList<Community*> joinedCommunities;
    QList<QString> joinedCommunitiesIds;

    QList<Event*> unsentMessages;

    QMap<QString, Member*> idToMember;
    QMap<QString, Community*> idToCommunity;
    QMap<QString, Room*> idToRoom;

    QString typingText;

    QList<Emote*> emotes;

    bool firstSync = true, traversingHistory = false;
    bool markdownEnabled = true;
};
