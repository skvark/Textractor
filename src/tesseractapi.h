#ifndef TESSERACTAPI_H
#define TESSERACTAPI_H

#include <QObject>
#include <QString>
#include <QFuture>
#include <tesseract/baseapi.h>
#include <leptonica/allheaders.h>
#include <QFutureWatcher>
#include <QTimer>

class TesseractAPI : public QObject
{
    Q_OBJECT
public:
    explicit TesseractAPI(QObject *parent = 0);
    ~TesseractAPI();

    // Does the whole analyzing process
    Q_INVOKABLE void analyze(QString imagepath);

signals:
    // Emitted when the OCR is done,
    // text contains results text
    void analyzed(QString text);
    // Emitted when timer_ fires to update
    // the processing thread status to the UI
    void stateChanged(QString state);

public slots:
    // Handler for the QFutureWatcher result
    void handleAnalyzed();
    // Slot for _timer
    void update();

private:

tesseract::TessBaseAPI *api_;
QFutureWatcher<QString> *watcher_;
QString status_;
QTimer *timer_;

};

#endif // TESSERACTAPI_H
