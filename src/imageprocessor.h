#ifndef IMAGEPROCESSOR_H
#define IMAGEPROCESSOR_H

#include <tesseract/baseapi.h>
#include <QString>
#include <settings.h>
#include <QPair>

struct Info {
    int rotation;
    QString status;
    bool gallery;
};

Pix* preprocess(Pix *image, int sX, int sY,
                int threshold, int mincount,
                int bgval, int smoothX,
                int smoothY, float scoreFract);

void writeToDisk(Pix *img);

QString clean(char* outText, tesseract::TessBaseAPI *api, int confidence);

QString run(QString imagepath,
            ETEXT_DESC *monitor,
            tesseract::TessBaseAPI* api,
            SettingsManager *settings,
            Info &info);

#endif // IMAGEPROCESSOR_H
