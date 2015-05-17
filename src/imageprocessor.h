#ifndef IMAGEPROCESSOR_H
#define IMAGEPROCESSOR_H

#include <tesseract/baseapi.h>
#include <QString>
#include <settings.h>
#include <QPair>

Pix* preprocess(Pix *image, int sX, int sY,
                int threshold, int mincount,
                int bgval, int smoothX,
                int smoothY, float scoreFract);

void writeToDisk(Pix *img);

QString clean(char* outText, tesseract::TessBaseAPI *api);

QString run(QString imagepath,
            ETEXT_DESC *monitor,
            tesseract::TessBaseAPI* api,
            SettingsManager *settings,
            QPair<QString, int> &info);

#endif // IMAGEPROCESSOR_H
