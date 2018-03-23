#pragma once

#include <QNetworkAccessManager>
#include <QNetworkRequest>
#include <QJsonObject>
#include <QJsonDocument>
#include <QUrl>

#include "requestsender.h"

namespace network {
  extern QNetworkAccessManager* manager;
  extern QString homeserverURL, accessToken;

  template<typename Fn>
  inline void postJSON(const QString& path, const QJsonObject object, Fn&& fn) {
    QNetworkRequest request(homeserverURL + path);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
    request.setRawHeader("Authorization", accessToken.toLocal8Bit());

    const QByteArray jsonPost = QJsonDocument(object).toJson();

    request.setHeader(QNetworkRequest::ContentLengthHeader, QByteArray::number(jsonPost.size()));

    RequestSender* sender = new RequestSender(manager);
    sender->fn = fn;

    request.setOriginatingObject(sender);

    QObject::connect(manager, &QNetworkAccessManager::finished, sender, &RequestSender::finished);

    manager->post(request, jsonPost);
  }

  template<typename Fn, typename ProgressFn>
  inline void postBinary(const QString& path, const QByteArray data, const QString mimeType, Fn&& fn, ProgressFn&& progressFn) {
    QNetworkRequest request(homeserverURL + path);
    request.setHeader(QNetworkRequest::ContentTypeHeader, mimeType);
    request.setRawHeader("Authorization", accessToken.toLocal8Bit());

    request.setHeader(QNetworkRequest::ContentLengthHeader, QByteArray::number(data.size()));

    RequestSender* sender = new RequestSender(manager);
    sender->fn = fn;

    request.setOriginatingObject(sender);

    QObject::connect(manager, &QNetworkAccessManager::finished, sender, &RequestSender::finished);

    QNetworkReply* reply = manager->post(request, data);
    QObject::connect(reply, &QNetworkReply::uploadProgress, progressFn);
  }

  template<typename Fn>
  inline void post(const QString& path, Fn&& fn) {
    QNetworkRequest request(homeserverURL + path);
    request.setRawHeader("Authorization", accessToken.toLocal8Bit());

    RequestSender* sender = new RequestSender(manager);
    sender->fn = fn;

    request.setOriginatingObject(sender);

    QObject::connect(manager, &QNetworkAccessManager::finished, sender, &RequestSender::finished);

    manager->post(request, QByteArray());
  }

  inline void post(const QString& path) {
    QNetworkRequest request(homeserverURL + path);
    request.setRawHeader("Authorization", accessToken.toLocal8Bit());

    manager->post(request, QByteArray());
  }

  inline void putJSON(const QString& path, const QJsonObject object) {
    QNetworkRequest request(homeserverURL + path);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
    request.setRawHeader("Authorization", accessToken.toLocal8Bit());

    const QByteArray jsonPost = QJsonDocument(object).toJson();

    request.setHeader(QNetworkRequest::ContentLengthHeader, QByteArray::number(jsonPost.size()));

    manager->put(request, jsonPost);
  }

  template<typename Fn>
  inline void putJSON(const QString& path, const QJsonObject object, Fn&& fn) {
    QNetworkRequest request(homeserverURL + path);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
    request.setRawHeader("Authorization", accessToken.toLocal8Bit());

    RequestSender* sender = new RequestSender(manager);
    sender->fn = fn;

    request.setOriginatingObject(sender);

    const QByteArray jsonPost = QJsonDocument(object).toJson();

    request.setHeader(QNetworkRequest::ContentLengthHeader, QByteArray::number(jsonPost.size()));

    QObject::connect(manager, &QNetworkAccessManager::finished, sender, &RequestSender::finished);

    manager->put(request, jsonPost);
  }

  template<typename Fn>
  inline void get(const QString& path, Fn&& fn, const QString contentType = "application/json") {
    QNetworkRequest request(homeserverURL + path);
    request.setHeader(QNetworkRequest::ContentTypeHeader, contentType);
    request.setRawHeader("Authorization", accessToken.toLocal8Bit());

    RequestSender* sender = new RequestSender(manager);
    sender->fn = fn;

    request.setOriginatingObject(sender);

    QObject::connect(manager, &QNetworkAccessManager::finished, sender, &RequestSender::finished);

    manager->get(request);
  }
}
