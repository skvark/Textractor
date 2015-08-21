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

    Q_INVOKABLE void resetSettings();
    Q_INVOKABLE bool isLangDownloaded(QString lang);
    Q_INVOKABLE void downloadLanguage(QString lang);
    Q_INVOKABLE void deleteLanguage(QString lang);

    Q_INVOKABLE QString tesseractVersion();
    Q_INVOKABLE QString leptonicaVersion();

    SettingsManager *settings() const;

    bool isCancel();

    static bool cancelCallback(void *cancel_this, int words) {
        TesseractAPI* api = static_cast<TesseractAPI*>(cancel_this);
        return api->isCancel();
    }

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

public slots:
    // Handler for the QFutureWatcher result
    void handleAnalyzed();
    // Handler for the QFutureWatcher result
    void handleRotated();
    // Slot for _timer
    void update();

private:

    tesseract::TessBaseAPI* api_;
    QFutureWatcher<QString> *watcher_;
    QTimer *timer_;

    ETEXT_DESC *monitor_;

    SettingsManager *settingsManager_;
    DownloadManager *downloadManager_;

    Info info_;
    bool cancel_;

};

#endif // TESSERACTAPI_H
