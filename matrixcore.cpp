#include "matrixcore.h"

#include <QJsonArray>
#include <QRandomGenerator>
#include <QSettings>

#include "network.h"
#include "community.h"

MatrixCore::MatrixCore(QObject* parent) : QObject(parent), roomListModel(rooms), directoryListModel(publicRooms), eventModel(*this) {
    QSettings settings;
    homeserverURL = settings.value("homeserver", "matrix.org").toString();
    userId = settings.value("userId").toString();
    network::homeserverURL = "https://" + homeserverURL;

    if(settings.contains("accessToken"))
        network::accessToken = "Bearer " + settings.value("accessToken").toString();

    emptyRoom.setName("Empty");
    emptyRoom.setTopic("There is nothing here.");

    roomListSortModel.setSourceModel(&roomListModel);
    roomListSortModel.setSortRole(RoomListModel::SectionRole);

    connect(this, &MatrixCore::roomListChanged, [this] {
        roomListSortModel.sort(0);
    });

    directoryListSortModel.setSourceModel(&directoryListModel);

    updateAccountInformation();
}

void MatrixCore::registerAccount(const QString &username, const QString &password, const QString& session, const QString& type) {
    QJsonObject authObject;
    if(!session.isEmpty()) {
        authObject["type"] =  type;
        authObject["session"] = session;
    }

    const QJsonObject registerObject {
        {"auth", authObject},
        {"username", username},
        {"password", password}
    };

    network::postJSON("/_matrix/client/r0/register?kind=user", registerObject, [this](QNetworkReply* reply) {
        const QJsonDocument document = QJsonDocument::fromJson(reply->readAll());

        if(reply->error()) {
            if(document.object().contains("flows")) {
                const QString stage = document.object()["flows"].toArray()[0].toObject()["stages"].toArray()[0].toString();

                if(stage == "m.login.recaptcha") {
                    const QJsonObject data {
                        {"public_key", document.object()["params"].toObject()["m.login.recaptcha"].toObject()["public_key"].toString()},
                        {"session", document.object()["session"].toString()},
                        {"type", "m.login.recaptcha"}
                    };

                    emit registerFlow(data);
                } else if(stage == "m.login.dummy") {
                    const QJsonObject data {
                        {"session", document.object()["session"].toString()},
                        {"type", "m.login.dummy"}
                    };

                    emit registerFlow(data);
                } else {
                    emit registerAttempt(true, "Unknown stage type " + stage);
                }
            } else {
                emit registerAttempt(true, document.object()["error"].toString());
            }
        } else {
            network::accessToken = "Bearer " + document.object()["access_token"].toString();

            QSettings settings;
            settings.setValue("accessToken", document.object()["access_token"].toString());
            settings.setValue("userId", document.object()["user_id"].toString());
            settings.setValue("deviceId", document.object()["device_id"].toString());

            emit registerAttempt(false, "");
        }
    });
}

void MatrixCore::login(const QString& username, const QString& password) {
    const QJsonObject loginObject {
      {"type", "m.login.password"},
      {"user", username},
      {"password", password},
      {"initial_device_display_name", "Trinity"}
    };

    network::postJSON("/_matrix/client/r0/login", loginObject, [this](QNetworkReply* reply) {
        const QJsonDocument document = QJsonDocument::fromJson(reply->readAll());

        if(reply->error()) {
            emit loginAttempt(true, document.object()["error"].toString());
        } else {
            network::accessToken = "Bearer " + document.object()["access_token"].toString();

            QSettings settings;
            settings.setValue("accessToken", document.object()["access_token"].toString());
            settings.setValue("userId", document.object()["user_id"].toString());
            settings.setValue("deviceId", document.object()["device_id"].toString());

            emit loginAttempt(false, "");
        }
    });
}

void MatrixCore::logout() {
    network::post("/_matrix/client/r0/logout");

    QSettings settings;
    settings.remove("accessToken");
    settings.remove("deviceId");
    settings.remove("userId");
    settings.sync();
}

void MatrixCore::updateAccountInformation() {
    network::get("/_matrix/client/r0/profile/@" + userId + "/displayname", [this](QNetworkReply* reply) {
        const QJsonDocument document = QJsonDocument::fromJson(reply->readAll());

        displayName = document.object()["displayname"].toString();
        emit displayNameChanged();
    });
}

void MatrixCore::setDisplayName(const QString& name) {
    displayName = name;

    const QJsonObject displayNameObject {
        {"displayname", name}
    };

    network::putJSON("/_matrix/client/r0/profile/@" + userId + "/displayname", displayNameObject, [this, name](QNetworkReply* reply) {
        emit displayNameChanged();
    });
}

void MatrixCore::sync() {
    if(network::accessToken.isEmpty())
        return;

    QString url = "/_matrix/client/r0/sync";
    if(!nextBatch.isEmpty())
        url += "?since=" + nextBatch;

    network::get(url, [this](QNetworkReply* reply) {
        const QJsonDocument document = QJsonDocument::fromJson(reply->readAll());

        if(!document.object()["next_batch"].isNull())
          nextBatch = document.object()["next_batch"].toString();

        const auto createRoom = [this](const QString id, const QString joinState) {
            roomListModel.beginInsertRoom();

            Room* room = new Room(this);
            room->setId(id);
            room->setJoinState(joinState);

            network::get("/_matrix/client/r0/rooms/" + id + "/state/m.room.name", [this, room](QNetworkReply* reply) {
                const QJsonDocument document = QJsonDocument::fromJson(reply->readAll());
                if(document.object()["errcode"].toString() == "M_GUEST_ACCESS_FORBIDDEN") {
                    room->setGuestDenied(true);
                    return;
                } else if(document.object()["errcode"].toString() == "M_NOT_FOUND")
                    return;

                room->setName(document.object()["name"].toString());

                roomListModel.updateRoom(room);
            });

            network::get("/_matrix/client/r0/rooms/" + id + "/state/m.room.topic", [this, room](QNetworkReply* reply) {
                const QJsonDocument document = QJsonDocument::fromJson(reply->readAll());
                if(document.object()["errcode"].toString() == "M_GUEST_ACCESS_FORBIDDEN") {
                    room->setGuestDenied(true);
                    return;
                }

                room->setTopic(document.object()["topic"].toString());

                roomListModel.updateRoom(room);
            });

            network::get("/_matrix/client/r0/rooms/" + id + "/state/m.room.avatar", [this, room](QNetworkReply* reply) {
                const QJsonDocument document = QJsonDocument::fromJson(reply->readAll());
                if(document.object()["errcode"].toString() == "M_GUEST_ACCESS_FORBIDDEN") {
                    room->setGuestDenied(true);
                    return;
                }

                if(document.object().contains("url")) {
                    const QString imageId = document.object()["url"].toString().remove("mxc://");
                    room->setAvatar(network::homeserverURL + "/_matrix/media/r0/thumbnail/" + imageId + "?width=64&height=64&method=scale");
                }

                roomListModel.updateRoom(room);
            });

            rooms.push_back(room);
            idToRoom.insert(id, room);

            roomListModel.endInsertRoom();

            emit roomListChanged();

            updateMembers(room);

            return room;
        };

        for(const auto id : document.object()["rooms"].toObject()["invite"].toObject().keys()) {
            if(!invitedRooms.count(id)) {
                Room* room = createRoom(id, "Invited");

                for(auto event : document.object()["rooms"].toObject()["invite"].toObject()[id].toObject()["invite_state"].toObject()["events"].toArray()) {
                    const QString type = event.toObject()["type"].toString();

                    if(type == "m.room.member")
                        room->setInvitedBy(event.toObject()["sender"].toString());
                    else if(type == "m.room.name") {
                        room->setName(event.toObject()["content"].toObject()["name"].toString());
                    } else if(type == "m.room.avatar") {
                        const QString imageId = event.toObject()["content"].toObject()["url"].toString().remove("mxc://");
                        room->setAvatar(network::homeserverURL + "/_matrix/media/r0/thumbnail/" + imageId + "?width=64&height=64&method=scale");
                    }

                    roomListModel.updateRoom(room);
                }

                invitedRooms.push_back(id);
            }
        }

        for(const auto id : document.object()["rooms"].toObject()["join"].toObject().keys()) {
            if(!joinedRooms.count(id)) {
                createRoom(id, "Joined");
                joinedRooms.push_back(id);
            }
        }

        for(const auto id : document.object()["rooms"].toObject()["leave"].toObject().keys()) {

            if(joinedRooms.count(id)) {
                Room* room = resolveRoomId(id);
                room->setJoinState("left");

                joinedRooms.removeOne(id);
                rooms.removeOne(room);

                roomListModel.fullUpdate();
            }
        }

        unsigned int i = 0;
        for(const auto& room : document.object()["rooms"].toObject()["join"].toObject()) {
            Room* roomState = nullptr;
            for(auto& r : rooms) {
              if(r->getId() == document.object()["rooms"].toObject()["join"].toObject().keys()[i])
                roomState = r;
            }

            if(!roomState)
                continue;

            if(firstSync)
                roomState->prevBatch = room.toObject()["timeline"].toObject()["prev_batch"].toString();

            const int highlightCount = room.toObject()["unread_notifications"].toObject()["highlight_count"].toInt();
            const int notificationCount = room.toObject()["unread_notifications"].toObject()["notification_count"].toInt();

            if(highlightCount != roomState->getHighlightCount()) {
                roomState->setNotificationCount(highlightCount);
                roomListModel.updateRoom(roomState);
            }

            if(notificationCount != roomState->getNotificationCount()) {
                roomState->setNotificationCount(notificationCount);
                roomListModel.updateRoom(roomState);
            }

            for(const auto event : room.toObject()["ephemeral"].toObject()["events"].toArray()) {
                const QString eventType = event.toObject()["type"].toString();

                if(eventType == "m.typing") {
                    auto typing = event.toObject()["content"].toObject()["user_ids"].toArray();

                    QString typingText;
                    int trueSize = 0;
                    if(typing.size() < 4) {
                        for(int i = 0; i < typing.size(); i++) {
                            if(typing[i].toString() == userId)
                                continue;

                            typingText += resolveMemberId(typing[i].toString())->getDisplayName();
                            if(i != typing.size() - 1)
                                typingText += ", ";

                            trueSize++;
                        }

                        typingText += " is";
                    } else {
                        typingText = "Several people are";
                    }

                    if(trueSize != 0)
                        this->typingText = typingText + " typing...";
                    else
                        this->typingText.clear();

                    emit typingTextChanged();
                }
            }

            for(const auto event : room.toObject()["timeline"].toObject()["events"].toArray())
                consumeEvent(event.toObject(), *roomState);

            i++;
        }

        for(const auto& id : document.object()["groups"].toObject()["join"].toObject().keys()) {
            if(!joinedCommunitiesIds.count(id)) {
                Community* community = nullptr;
                if(!idToCommunity.count(id))
                    community = createCommunity(id);
                else
                    community = idToCommunity[id];

                community->setJoinState("Joined");

                joinedCommunities.push_back(community);
                joinedCommunitiesIds.push_back(community->getId());

                emit joinedCommunitiesChanged();
            }
        }

        if(firstSync) {
            firstSync = false;
            emit initialSyncFinished();
        }

        emit syncFinished();
    });
}

void MatrixCore::sendMessage(Room* room, const QString& message) {
    const QJsonObject messageObject {
        {"msgtype", "m.text"},
        {"body", message}
    };

    Event* e = new Event(room);
    e->setSender(userId);
    e->timestamp = QDateTime::currentDateTime();
    e->setMsg(message);
    e->setRoom(room->getId());
    e->sent = false;

    eventModel.beginUpdate(0);
    room->events.push_front(e);
    eventModel.endUpdate();

    unsentMessages.push_back(e);

    network::putJSON(QString("/_matrix/client/r0/rooms/" + room->getId() + "/send/m.room.message/") + QRandomGenerator::global()->generate(), messageObject, [this, e](QNetworkReply* reply) {
        if(!reply->error()) {
            for(size_t i = 0; i < unsentMessages.size(); i++) {
                if(unsentMessages[i] == e)
                    e->sent = true;
            }
        }
    });
}

void MatrixCore::removeMessage(const QString& eventId) {
    const QJsonObject reasonObject {
      {"reason", ""}
    };

    network::putJSON("/_matrix/client/r0/rooms/" + currentRoom->getId() + "/redact/" + eventId + "/" + QRandomGenerator::global()->generate(), reasonObject, [this, eventId](QNetworkReply* reply) {
        auto& events = currentRoom->events;
        for(int i = 0; i < events.size(); i++) {
            if(events[i]->eventId == eventId) {
                eventModel.beginRemoveEvent(i, 0);

                events.removeAt(i);

                eventModel.endRemoveEvent();
            }
        }
    });
}

void MatrixCore::startDirectChat(const QString& id) {
    const QJsonObject roomObject {
        {"visibility", "private"},
        {"creation_content", QJsonObject{{"m.federate", false}}},
        {"preset", "private_chat"},
        {"is_direct", true},
        {"invite", QJsonArray{id}}
    };

    network::postJSON("/_matrix/client/r0/createRoom", roomObject, [](QNetworkReply*) {});
}

void MatrixCore::setTyping(Room* room) {
    const QJsonObject typingObject {
      {"typing", true},
      {"timeout", 15000}
    };

    network::putJSON("/_matrix/client/r0/rooms/" + room->getId() + "/typing/" + userId, typingObject);
}

void MatrixCore::joinRoom(const QString& id) {
    network::post("/_matrix/client/r0/rooms/" + id + "/join", [this, id](QNetworkReply* reply) {
        if(!reply->error()) {
            //check if its by an invite
            if(invitedRooms.contains(id)) {
                invitedRooms.removeOne(id);
                joinedRooms.push_back(id);

                for(const auto roomObject : rooms) {
                    if(roomObject->getId() == id) {
                        roomObject->setJoinState("Joined");
                        roomObject->setGuestDenied(false);

                        emit roomListChanged();

                        return;
                    }
                }
            }
        }
    });
}

void MatrixCore::leaveRoom(const QString& id) {
    network::post("/_matrix/client/r0/rooms/" + id + "/leave");
}

void MatrixCore::inviteToRoom(Room* room, const QString& userId) {
    const QJsonObject inviteObject {
        {"user_id", userId}
    };

    network::postJSON("/_matrix/client/r0/rooms/" + room->getId() + "/invite", inviteObject, [](QNetworkReply*) {});
}

void MatrixCore::updateMembers(Room* room) {
    if(!room)
        return;

    network::get("/_matrix/client/r0/rooms/" + room->getId() + "/members", [this, room](QNetworkReply* reply) {
        const QJsonDocument document = QJsonDocument::fromJson(reply->readAll());

        const QJsonArray& chunk = document.object()["chunk"].toArray();

        size_t realSize = 0;
        for(const auto& member : chunk) {
            if(member.toObject()["content"].toObject()["membership"].toString() == "join")
                realSize++;
        }

        if(room->members.size() != realSize) {
            room->members.clear();
            room->members.reserve(realSize);

            for(const auto& member : chunk) {
                const QJsonObject& memberJson = member.toObject();

                if(memberJson["content"].toObject()["membership"].toString() == "join") {
                    const QString& id = memberJson["state_key"].toString();

                    Member* m = nullptr;
                    if(!idToMember.contains(id)) {
                        m = new Member(this);
                        m->setId(id);
                        m->setDisplayName(memberJson["content"].toObject()["displayname"].toString());

                        if(!memberJson["content"].toObject()["avatar_url"].isNull()) {
                            const QString imageId = memberJson["content"].toObject()["avatar_url"].toString().remove("mxc://");
                            m->setAvatar(network::homeserverURL + "/_matrix/media/r0/thumbnail/" + imageId + "?width=64&height=64&method=scale");
                        }

                        idToMember.insert(id, m);
                    } else {
                        m = idToMember[id];
                    }

                    if(currentRoom == room) {
                        eventModel.updateEventsByMember(id);

                        memberModel.beginUpdate(0);
                    }

                    room->members.push_back(m);

                    if(currentRoom == room)
                        memberModel.endUpdate();
                }
            }
        }
    });
}

void MatrixCore::readMessageHistory(Room* room) {
    if(!room || room->prevBatch.isEmpty())
        return;

    network::get("/_matrix/client/r0/rooms/" + room->getId() + "/messages?from=" + room->prevBatch + "&dir=b", [this, room](QNetworkReply* reply) {
        const QJsonDocument document = QJsonDocument::fromJson(reply->readAll());

        room->prevBatch = document.object()["end"].toString();

        traversingHistory = true;

        for(const auto event : document.object()["chunk"].toArray())
            consumeEvent(event.toObject(), *room, false);

        traversingHistory = false;
    });
}

void MatrixCore::updateMemberCommunities(Member* member) {
    if(!member)
        return;

    const QJsonArray userIdsArray {
        {member->getId()}
    };

    const QJsonObject userIdsObject {
        {"user_ids", userIdsArray}
    };

    network::postJSON("/_matrix/client/r0/publicised_groups", userIdsObject, [this, member](QNetworkReply* reply) {
        const QJsonDocument document = QJsonDocument::fromJson(reply->readAll());

        for(const auto id : document.object()["users"].toObject()[member->getId()].toArray()) {
            bool found = false;
            for(const auto community : member->getPublicCommunities()) {
                if(community->getId() == id.toString())
                    found = true;
            }

            if(!found) {
                Community* community = nullptr;
                if(!idToCommunity.count(id.toString()))
                    community = createCommunity(id.toString());
                else
                    community = idToCommunity[id.toString()];

                member->addCommunity(community);
            }
        }
    });
}

bool MatrixCore::settingsValid() {
    QSettings settings;
    return settings.contains("accessToken");
}

void MatrixCore::setHomeserver(const QString& url) {
    network::homeserverURL = "https://" + url;

    network::get("/_matrix/client/versions", [this, url](QNetworkReply* reply) {
       if(!reply->error()) {
           homeserverURL = url;

           QSettings settings;
           settings.setValue("homeserver", url);
       }

       network::homeserverURL = "https://" + homeserverURL;

       emit homeserverChanged(reply->error() == 0, reply->errorString());
    });
}

void MatrixCore::changeCurrentRoom(Room* room) {
    currentRoom = room;

    eventModel.setRoom(room);
    eventModel.fullUpdate();

    memberModel.setRoom(room);
    memberModel.fullUpdate();

    emit currentRoomChanged();
}

void MatrixCore::changeCurrentRoom(const unsigned int index) {
    if(index < rooms.size())
        changeCurrentRoom(rooms[index]);
    else
        changeCurrentRoom(&emptyRoom);
}

Member* MatrixCore::resolveMemberId(const QString& id) const {
    return idToMember.value(id);
}

Community* MatrixCore::resolveCommunityId(const QString &id) const {
    return idToCommunity.value(id);
}

Room* MatrixCore::resolveRoomId(const QString &id) const {
    return idToRoom.value(id);
}

Room* MatrixCore::getRoom(const unsigned int index) const {
    return rooms[index];
}

QString MatrixCore::getUsername() const {
    QString id = userId;
    return id.remove('@').split(':')[0];
}

void MatrixCore::loadDirectory() {
    const QJsonObject bodyObject;

    network::postJSON("/_matrix/client/r0/publicRooms", bodyObject, [this](QNetworkReply* reply) {
        const QJsonDocument document = QJsonDocument::fromJson(reply->readAll());

        if(publicRooms.size() != document.object()["chunk"].toArray().size()) {
            publicRooms.clear();
            publicRooms.reserve(document.object()["chunk"].toArray().size());

            for(const auto room : document.object()["chunk"].toArray()) {
                const QJsonObject& roomObject = room.toObject();
                const QString& roomId = roomObject["room_id"].toString();

                Room* r = nullptr;
                if(!idToRoom.contains(roomId)) {
                    r = new Room(this);
                    r->setId(roomId);
                    r->setName(roomObject["name"].toString());

                    if(!roomObject["avatar_url"].isNull()) {
                        const QString imageId = roomObject["avatar_url"].toString().remove("mxc://");
                        r->setAvatar(network::homeserverURL + "/_matrix/media/r0/thumbnail/" + imageId + "?width=64&height=64&method=scale");
                    }

                    r->setTopic(roomObject["topic"].toString());

                    idToRoom.insert(roomId, r);
                } else {
                    r = idToRoom.value(roomId);
                }

                directoryListModel.beginInsertRoom();
                publicRooms.push_back(r);
                directoryListModel.endInsertRoom();

                emit publicRoomsChanged();
            }
        }
    });
}

void MatrixCore::readUpTo(Room* room, const int index) {
    if(!room)
        return;

    if(room->events.size() == 0)
        return;

    if(index < 0)
        return;

    network::post("/_matrix/client/r0/rooms/" + room->getId() + "/receipt/m.read/" + room->events[index]->eventId);
}

Room* MatrixCore::getCurrentRoom() {
    return currentRoom != nullptr ? currentRoom : &emptyRoom;
}

EventModel* MatrixCore::getEventModel() {
    return &eventModel;
}

RoomListSortModel* MatrixCore::getRoomListModel() {
    return &roomListSortModel;
}

RoomListSortModel* MatrixCore::getDirectoryListModel() {
    return &directoryListSortModel;
}

MemberModel* MatrixCore::getMemberModel() {
    return &memberModel;
}

QString MatrixCore::getHomeserverURL() const {
    return homeserverURL;
}

void MatrixCore::consumeEvent(const QJsonObject& event, Room& room, const bool insertFront) {
    const QString eventType = event["type"].toString();

    const auto addEvent = [&room, insertFront, this](Event* object) {
        if(insertFront) {
            if(&room == currentRoom)
                eventModel.beginUpdate(0);

            room.events.push_front(object);

            if(&room == currentRoom)
                eventModel.endHistory();
        } else {
            if(&room == currentRoom)
                eventModel.beginHistory(0);

            room.events.push_back(object);

            if(&room == currentRoom)
                eventModel.endHistory();
        }
    };

    bool found = false;
    if(eventType == "m.room.message") {
        for(size_t i = 0; i < unsentMessages.size(); i++) {
            if(event["sender"].toString() == userId && unsentMessages[i]->getRoom() == room.getId()) {
                found = true;
                if(currentRoom == &room)
                    eventModel.updateEvent(unsentMessages[i]);

                unsentMessages.removeAt(i);
            }
        }
    } else if(eventType == "m.room.member") {
        // avoid events tied to us
        if(event["state_key"].toString() == userId)
            return;

        if(event["content"].toObject().contains("is_direct"))
            room.setDirect(event["content"].toObject()["is_direct"].toBool());

        if(room.getDirect()) {
            room.setName(event["content"].toObject()["displayname"].toString());

            if(!event["content"].toObject()["avatar_url"].isNull()) {
                const QString imageId = event["content"].toObject()["avatar_url"].toString().remove("mxc://");
                room.setAvatar(network::homeserverURL + "/_matrix/media/r0/thumbnail/" + imageId + "?width=64&height=64&method=scale");
            }
        }

        roomListModel.updateRoom(&room);
    } else
        return;

    // don't show redacted messages
    if(event["unsigned"].toObject().keys().contains("redacted_because"))
        return;

    if(!found && eventType == "m.room.message") {
        const QString msgType = event["content"].toObject()["msgtype"].toString();
        if(msgType != "m.text")
            return;

        Event* e = new Event(&room);

        e->timestamp = QDateTime(QDate::currentDate(),
                                 QTime(QTime::currentTime().hour(),
                                       QTime::currentTime().minute(),
                                       QTime::currentTime().second(),
            QTime::currentTime().msec() - event["unsigned"].toObject()["age"].toInt()));

        e->setSender(event["sender"].toString());
        e->eventId = event["event_id"].toString();
        e->setMsg(event["content"].toObject()["body"].toString());

        addEvent(e);

        if(!firstSync && !traversingHistory)
            emit message(e->getSender(), e->getMsg());
    }
}

Community* MatrixCore::createCommunity(const QString& id) {
    Community* community = new Community(this);
    community->setId(id);

    network::get("/_matrix/client/r0/groups/" + community->getId() + "/summary", [this, community](QNetworkReply* reply) {
        const QJsonDocument document = QJsonDocument::fromJson(reply->readAll());

        const QJsonObject& profile = document.object()["profile"].toObject();

        community->setName(profile["name"].toString());

        if(!profile["avatar_url"].isNull()) {
            const QString imageId = profile["avatar_url"].toString().remove("mxc://");
            community->setAvatar(network::homeserverURL + "/_matrix/media/r0/thumbnail/" + imageId + "?width=64&height=64&method=scale");
        }

        community->setShortDescription(profile["short_description"].toString());
        community->setLongDescription(profile["long_description"].toString());

        idToCommunity.insert(community->getId(), community);
    });

    return community;
}

QString MatrixCore::getDisplayName() const {
    return displayName;
}

QVariantList MatrixCore::getJoinedCommunitiesList() const {
    QVariantList list;
    for(const auto community : joinedCommunities)
        list.push_back(QVariant::fromValue(community));

    return list;
}

QString MatrixCore::getTypingText() const {
    return typingText;
}
