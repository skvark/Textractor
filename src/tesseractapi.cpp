#include "tesseractapi.h"
#include <QByteArray>
#include <QDebug>
#include <QtConcurrent/QtConcurrent>
#include <QNetworkReply>

TesseractAPI::TesseractAPI(QObject *parent) :
    QObject(parent)
{
    QTextCodec::setCodecForLocale(QTextCodec::codecForName("utf-8"));
    timer_ = new QTimer(this);
    monitor_ = new ETEXT_DESC();
    settingsManager_ = new SettingsManager();
    downloadManager_ = new DownloadManager();

    QObject::connect(downloadManager_, SIGNAL(downloaded(QString)),
                     this, SIGNAL(languageExtracting(QString)));
    QObject::connect(downloadManager_, SIGNAL(extracted(QString)),
                     this, SIGNAL(languageReady(QString)));

    api_ = new tesseract::TessBaseAPI();

    if (settingsManager_->getLanguageCode().length() == 0) {
        settingsManager_->resetToDefaults();
        QTimer::singleShot(200, this, SIGNAL(firstUse()));
    }

    info_ = Info();
    cancel_ = false;

}

TesseractAPI::~TesseractAPI()
{
    delete monitor_;
    monitor_ = 0;
    delete settingsManager_;
    settingsManager_ = 0;
    delete downloadManager_;
    downloadManager_ = 0;
    delete timer_;
    timer_ = 0;
    api_->End();
    delete api_;
    api_ = 0;
}

void TesseractAPI::analyze(QString imagepath, int rotation, bool gallery)
{
    // Run the cpu-heavy stuff in another thread.
    watcher_ = new QFutureWatcher<QString>();
    connect(watcher_, SIGNAL(finished()), this, SLOT(handleAnalyzed()));

    monitor_->progress = 0;
    monitor_->cancel = (CANCEL_FUNC)&TesseractAPI::cancelCallback;
    monitor_->cancel_this = this;
    info_.status = QString("Initializing...");
    info_.rotation = rotation;
    info_.gallery = gallery;

    // Since the QtConcurrent::run creates internal copies of the parameters
    // the status parameter is passed as wrapped reference using std::ref().
    // Note that std::ref is a C++11 feature.
    QFuture<QString> future = QtConcurrent::run(run, imagepath, monitor_, api_, settingsManager_, std::ref(info_));
    watcher_->setFuture(future);

    // Periodically firing timer to get progress reports to the UI.
    connect(timer_, SIGNAL(timeout()), this, SLOT(update()));
    timer_->start(500);
}

void TesseractAPI::cancel()
{
    cancel_ = true;
}

void TesseractAPI::resetSettings()
{
    settingsManager_->resetToDefaults();
    emit reset();
}

bool TesseractAPI::isLangDownloaded(QString lang)
{
    return settingsManager_->isLangDataAvailable(lang);
}

void TesseractAPI::downloadLanguage(QString lang)
{
    QNetworkReply* reply = downloadManager_->downloadFile(settingsManager_->getLanguageCode(lang));
    QObject::connect(reply, SIGNAL(downloadProgress(qint64, qint64)),
                     this, SIGNAL(progressStatus(qint64, qint64)));
}

void TesseractAPI::deleteLanguage(QString lang)
{
    return;
}

QString TesseractAPI::tesseractVersion()
{
    static const char* version = api_->Version();
    return QString(QByteArray::fromRawData(version, sizeof(version)));
}

QString TesseractAPI::leptonicaVersion()
{
    QString version(QString::number(LIBLEPT_MAJOR_VERSION) + "." + QString::number(LIBLEPT_MINOR_VERSION));
    return version;
}

SettingsManager *TesseractAPI::settings() const
{
    return settingsManager_;
}

bool TesseractAPI::isCancel()
{
    if(cancel_) {
        cancel_ = false;
    } else {
        return false;
    }
    return true;
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
    if(info_.status == "Running OCR...") {
        emit percentageChanged(monitor_->progress);
    }
    emit stateChanged(info_.status);
}
