#ifndef TESSERACTAPI_H
#define TESSERACTAPI_H

#include <QObject>
#include <QString>
#include <QFuture>
#include <tesseract/baseapi.h>
#include <leptonica/allheaders.h>
#include <QFutureWatcher>

class TesseractAPI : public QObject
{
    Q_OBJECT
public:
    explicit TesseractAPI(QObject *parent = 0);
    Q_INVOKABLE void analyze(QString imagepath);

signals:
    void analyzed(QString text);

public slots:
    void handleAnalyzed();

private:

tesseract::TessBaseAPI *api_;
QFutureWatcher<QString> *watcher_;

};

#endif // TESSERACTAPI_H
