#ifndef TESSERACTAPI_H
#define TESSERACTAPI_H

#include <QObject>
#include <QString>
#include <QFuture>
#include "tesseract/baseapi.h"
#include "tesseract/ocrclass.h"
#include <leptonica/allheaders.h>
#include <QFutureWatcher>
#include <QTimer>
#include <settings.h>
#include <downloadmanager.h>
#include "imageprocessor.h"
#include "pdfhandler.h"
#include "PDFThumbnailProvider.h"


class TesseractAPI : public QObject
{
    Q_OBJECT
    Q_PROPERTY(SettingsManager* settings READ settings CONSTANT)

public:
    explicit TesseractAPI(QObject *parent = 0);
    ~TesseractAPI();

    // Does the whole analyzing process
    Q_INVOKABLE void analyze(QString imagepath, QVariant cropPoints);
    Q_INVOKABLE void prepareForCropping(QString imagepath, int rotation, bool gallery);
    Q_INVOKABLE void cancel();

    Q_INVOKABLE void analyzePDF(QList<int> pages);

    Q_INVOKABLE void resetSettings();
    Q_INVOKABLE bool isLangDownloaded(QString lang);
    Q_INVOKABLE void downloadLanguage(QString lang);

    Q_INVOKABLE QString tesseractVersion();
    Q_INVOKABLE QString leptonicaVersion();
    Q_INVOKABLE QString homePath();

    SettingsManager *settings() const;

    bool isCancel();
    Q_INVOKABLE void setRotated(bool state);
    Q_INVOKABLE bool getRotated();
    Q_INVOKABLE QString getRotatedPath();
    Q_INVOKABLE QString getPrepdPath();
    Q_INVOKABLE bool thumbsReady();

    static bool cancelCallback(void *cancel_this, int words) {
        Q_UNUSED(words);
        TesseractAPI* api = static_cast<TesseractAPI*>(cancel_this);
        return api->isCancel();
    }

    PDFThumbnailProvider *getThumbnailProvider();
    Q_INVOKABLE void getThumbnails(QString path);
    Q_INVOKABLE QStringList getIdsList();

signals:
    // Emitted when the OCR is done,
    // text contains results text
    void analyzed(QString text);
    // Emitted when timer_ fires to update
    // the processing thread status to the UI
    void stateChanged(QString state);
    void percentageChanged(int percentage);
    void firstUse();
    void reset();
    void languageExtracting(QString lang);
    void languageReady(QString lang);
    void progressStatus(qint64 downloaded, qint64 total);
    void rotated(QString path);
    void thumbnailsReady(QStringList ids);
    void progressChanged(QString pstatus);

public slots:
    // Handler for the QFutureWatcher result
    void handleAnalyzed();
    // Handler for the QFutureWatcher result
    void handleRotated();
    // Handler for the QFutureWatcher result
    void handleThumbnails();
    // Slot for _timer
    void update();
    void updatePDFStatus();

private:

    tesseract::TessBaseAPI* api_;
    QFutureWatcher<QString> *watcher_;
    QFutureWatcher<QStringList> *PDFwatcher_;
    QTimer *timer_;
    QString status_;
    QString rotatedPath_;
    bool rotated_;
    bool thumbsReady_;
    unsigned int previousPage_;

    ETEXT_DESC *monitor_;

    SettingsManager *settingsManager_;
    DownloadManager *downloadManager_;
    PDFHandler* PDFhandler_;
    PDFThumbnailProvider* thumbnailProvider_;

    Info info_;
    bool cancel_;

};

#endif // TESSERACTAPI_H
