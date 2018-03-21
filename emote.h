#pragma once

#include <QString>

class Emote : public QObject {
    Q_OBJECT
    Q_PROPERTY(QString path MEMBER path)
    Q_PROPERTY(QString name MEMBER name)
public:
    QString path, name;
};
