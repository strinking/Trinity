#pragma once

#include <functional>
#include <QObject>
#include <QNetworkReply>
#include <QNetworkRequest>

class RequestSender : public QObject
{
    Q_OBJECT
public:
    RequestSender(QObject* parent = nullptr) : QObject(parent) {}

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

            deleteLater();
            reply->deleteLater();
        }
    }
};

Q_DECLARE_METATYPE(RequestSender)
