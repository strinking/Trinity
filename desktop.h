#pragma once

#include <QSystemTrayIcon>
#include <QApplication>

class Desktop : public QObject
{
    Q_OBJECT
public:
    Q_INVOKABLE void showTrayIcon(const bool shouldHide) {
        QApplication::setQuitOnLastWindowClosed(shouldHide);

        if(shouldHide)
            icon->hide();
        else
            icon->show();
    }

    Q_INVOKABLE void showMessage(const QString content) {
        icon->showMessage("Trinity", content);
    }

    QSystemTrayIcon* icon;
};
