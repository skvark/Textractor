#ifndef IMAGEPROCESSOR_H
#define IMAGEPROCESSOR_H

#include <tesseract/baseapi.h>
#include <QString>
#include <settings.h>
#include <QPair>
#include <QImage>
#include <QMap>
#include <QPointF>
#include <QList>
#include "pdfhandler.h"

struct Info {
    int rotation;
    QString status;
    QString prepdPath;
    bool gallery;
    QList<int> pages;
    QMap<QString, QVariant> cropPoints;
};

Pix* preprocess(Pix *image, int sX, int sY,
                int threshold, int mincount,
                int bgval, int smoothX,
                int smoothY, float scoreFract);

QString writeToDisk(Pix *img);

int getOrientation(char *imgPath);

QImage rotateByExif(int orientation, QImage img);

QString clean(char* outText, tesseract::TessBaseAPI *api, int confidence);

QString rotate(QString imagepath, Info &info);

void crop(QString imagepath, Info &info);

QString run(QString imagepath,
            ETEXT_DESC *monitor,
            tesseract::TessBaseAPI* api,
            SettingsManager *settings,
            Info &info);

QString runPDF(PDFHandler* pdf,
               ETEXT_DESC* monitor,
               tesseract::TessBaseAPI* api,
               SettingsManager *settings,
               Info &info);

#endif // IMAGEPROCESSOR_H
