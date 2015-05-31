#include "dowloadmanager.h"
#include <QDir>
#include <QStandardPaths>
#include <QFile>
#include <QUrl>
#include <QDebug>

QString downloadUrl("http://tesseract-ocr.googlecode.com/files/tesseract-ocr-3.02.");
QString fileName("tesseract-ocr-3.02.");
QString fileType(".tar.gz");

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

void DownloadManager::extracted(int exitCode, QProcess::ExitStatus exitStatus)
{
    if(exitStatus == QProcess::NormalExit) {
        QString dataDir = QStandardPaths::writableLocation(QStandardPaths::DataLocation);
        QString path = dataDir + "/" + fileName + language_ + fileType;
        QFile::remove(path);
        emit extracted(language_);
    }
}

bool DownloadManager::checkError(QNetworkReply *finished)
{
    if (finished->error() != QNetworkReply::NoError)
    {
        emit networkError(finished->error());
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
    QString path = dataDir + "/" + fileName + language + fileType;

    QFile file(path);
    file.open(QIODevice::WriteOnly);
    qint64 bytes = file.write(data);
    if(bytes == -1) {
        qDebug() << "write error";
    }
    file.close();

    emit downloaded(language);

    QStringList argList;
    argList.append("-xzf");
    argList.append(path);
    argList.append("-C");
    argList.append(dataDir);

    QObject::connect(process_, SIGNAL(finished(int, QProcess::ExitStatus)),
                     this, SLOT(extracted(int, QProcess::ExitStatus)));

    process_->start("tar", argList, QIODevice::ReadOnly);

    finished->deleteLater();
}
