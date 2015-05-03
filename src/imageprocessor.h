#ifndef IMAGEPROCESSOR_H
#define IMAGEPROCESSOR_H

#include <tesseract/baseapi.h>
#include <QString>
#include <settings.h>

Pix *preprocess(Pix *image, int sX, int sY, int smoothX, int smoothY, float scoreFract);

void writeToDisk(Pix *img);

QString clean(char* outText, tesseract::TessBaseAPI *api);

QString run(QString imagepath,
            tesseract::TessBaseAPI* api,
            QString &status,
            ETEXT_DESC *monitor,
            SettingsManager *settings);

#endif // IMAGEPROCESSOR_H
