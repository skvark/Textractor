#include "downloadmanager.h"
#include <QDir>
#include <QStandardPaths>
#include <QFile>
#include <QUrl>
#include <QDebug>

QString downloadUrl("https://raw.githubusercontent.com/tesseract-ocr/tessdata/3.04.00/");
QString dataFolder("/tesseract-ocr/3.05/tessdata/");
QString fileType(".traineddata");

DownloadManager::DownloadManager(QObject *parent) :
    QObject(parent)
{
    process_ = new QProcess();
    QObject::connect(&nam_, SIGNAL(finished(QNetworkReply*)),
                     this, SLOT(finished(QNetworkReply*)));
}

DownloadManager::~DownloadManager()
{
    delete process_;
    process_ = 0;
}

QNetworkReply* DownloadManager::downloadFile(QString lang)
{
    language_ = lang;
    QUrl url(downloadUrl + lang + fileType);
    QNetworkRequest request(url);
    QNetworkReply *reply = nam_.get(request);
    hash_[reply] = lang;
    return reply;
}

void DownloadManager::finished(QNetworkReply *reply)
{
    if(hash_.contains(reply)) {
        dataFileRequest(reply, hash_[reply]);
    }
    hash_.remove(reply);
}

bool DownloadManager::checkError(QNetworkReply *finished)
{
    if (finished->error() != QNetworkReply::NoError)
    {
        qDebug() << finished->error();
        return true;
    }
    return false;
}

void DownloadManager::dataFileRequest(QNetworkReply *finished, QString language)
{
    if (checkError(finished))
        return;

    QByteArray data = finished->readAll();

    QString dataDir = QStandardPaths::writableLocation(QStandardPaths::DataLocation);
    QString path = dataDir + dataFolder + language + fileType;

    QFile file(path);
    file.open(QIODevice::WriteOnly);
    qint64 bytes = file.write(data);

    if(bytes == -1) {
        qDebug() << "write error";
    }
    file.close();

    emit downloaded(language);
    finished->deleteLater();
}
