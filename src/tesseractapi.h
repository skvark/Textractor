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

class TesseractAPI : public QObject
{
    Q_OBJECT
    Q_PROPERTY(SettingsManager* settings READ settings CONSTANT)

public:
    explicit TesseractAPI(QObject *parent = 0);
    ~TesseractAPI();

    // Does the whole analyzing process
    Q_INVOKABLE void analyze(QString imagepath, int rotation);
    SettingsManager *settings() const;

signals:
    // Emitted when the OCR is done,
    // text contains results text
    void analyzed(QString text);
    // Emitted when timer_ fires to update
    // the processing thread status to the UI
    void stateChanged(QString state);
    void percentageChanged(int percentage);
    void firstUse();

public slots:
    // Handler for the QFutureWatcher result
    void handleAnalyzed();
    // Slot for _timer
    void update();

private:

tesseract::TessBaseAPI *api_;
QFutureWatcher<QString> *watcher_;
QPair<QString, int> info_;
QTimer *timer_;

ETEXT_DESC *monitor_;

SettingsManager *settingsManager_;

};

#endif // TESSERACTAPI_H
