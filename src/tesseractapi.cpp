#include "tesseractapi.h"
#include <QByteArray>
#include <QDebug>
#include <QtConcurrent/QtConcurrent>
#include "imageprocessor.h"

TesseractAPI::TesseractAPI(QObject *parent) :
    QObject(parent)
{
    QTextCodec::setCodecForLocale(QTextCodec::codecForName("utf-8"));
    api_ = new tesseract::TessBaseAPI();
    if (api_->Init(NULL, "eng")) {
        qDebug() << "Could not initialize tesseract.";
    }
    timer_ = new QTimer(this);
    monitor_ = new ETEXT_DESC();
}

TesseractAPI::~TesseractAPI()
{
    // End the api (releases memory)
    api_->End();
    delete api_;
    api_ = 0;
    delete monitor_;
    monitor_ = 0;
}

void TesseractAPI::analyze(QString imagepath)
{
    // Run the cpu-heavy stuff in another thread.
    watcher_ = new QFutureWatcher<QString>();
    connect(watcher_, SIGNAL(finished()), this, SLOT(handleAnalyzed()));

    // Since the QtConcurrent::run creates internal copies of the parameters
    // the status parameter is passed as wrapped reference using std::ref().
    // Note that std::ref is a C++11 feature.
    monitor_->progress = 0;
    QFuture<QString> future = QtConcurrent::run(run, imagepath, api_, std::ref(status_), monitor_);
    watcher_->setFuture(future);

    // Periodically firing timer to get progress reports to the UI.
    connect(timer_, SIGNAL(timeout()), this, SLOT(update()));
    timer_->start(500);
}

void TesseractAPI::handleAnalyzed()
{
    // send results to the UI
    emit analyzed(watcher_->future().result());

    // disconnect and stop timer
    disconnect(timer_, SIGNAL(timeout()), this, SLOT(update()));
    timer_->stop();

    // disconnect and destroy the QFutureWatcher
    disconnect(watcher_, SIGNAL(finished()), this, SLOT(handleAnalyzed()));
    delete watcher_;
    watcher_ = 0;
}

void TesseractAPI::update() {
    if(status_ == "Running OCR...") {
        emit percentageChanged(monitor_->progress);
    }
    emit stateChanged(status_);
}
