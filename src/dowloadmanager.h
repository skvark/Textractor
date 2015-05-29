#ifndef DOWNLOADMANAGER_H
#define DOWNLOADMANAGER_H

#include <QObject>
#include <QByteArray>
#include <QNetworkAccessManager>
#include <QNetworkRequest>
#include <QNetworkReply>

class DownloadManager : public QObject
{
    Q_OBJECT
public:
    explicit DownloadManager(QObject *parent = 0);
    virtual ~DownloadManager();
    QNetworkReply* downloadFile(QString lang);

public slots:
    void finished(QNetworkReply *reply);

signals:
    void downloaded(QString language);
    void extracted(QString language);
    void networkError(QNetworkReply::NetworkError error);

private:

    QNetworkAccessManager nam_;
    QHash<QNetworkReply*, QString > hash_;

    bool checkError(QNetworkReply *finished);
    void dataFileRequest(QNetworkReply *finished, QString language);

};

#endif // DOWNLOADMANAGER_H
