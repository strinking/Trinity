#pragma once

#include <functional>
#include <QObject>
#include <QNetworkReply>
#include <QNetworkRequest>

class RequestSender : public QObject
{
    Q_OBJECT
public:
    RequestSender() = default;
    RequestSender(const RequestSender& other) {
        fn = other.fn;
    }

    ~RequestSender() {
        QObject::disconnect(this);
    }

    std::function<void(QNetworkReply*)> fn;

    void finished(QNetworkReply* reply) {
        if(reply->request().originatingObject() == this) {
            fn(reply);

            delete this; // TODO: what is this
        }
    }
};

Q_DECLARE_METATYPE(RequestSender)
