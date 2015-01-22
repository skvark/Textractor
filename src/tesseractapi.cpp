#include "tesseractapi.h"
#include <QByteArray>
#include <QDebug>
#include <QtConcurrent/QtConcurrent>
#include "imageprocessor.h"

TesseractAPI::TesseractAPI(QObject *parent) :
    QObject(parent)
{
    api_ = new tesseract::TessBaseAPI();
    if (api_->Init(NULL, "eng")) {
        qDebug() << "Could not initialize tesseract.";
    }
}

void TesseractAPI::analyze(QString imagepath)
{
    watcher_ = new QFutureWatcher<QString>();
    connect(watcher_, SIGNAL(finished()), this, SLOT(handleAnalyzed()));
    QFuture<QString> future = QtConcurrent::run(run, imagepath, api_);
    watcher_->setFuture(future);
}

void TesseractAPI::handleAnalyzed()
{
    emit analyzed(watcher_->future().result());
}
