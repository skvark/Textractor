#ifndef IMAGEPROCESSOR_H
#define IMAGEPROCESSOR_H

#include <tesseract/baseapi.h>
#include <QString>

extern Pix *preprocess(Pix *image, int sX, int sY, int smoothX, int smoothY, float scoreFract);
extern void writeToDisk(Pix *img);
extern QString clean(char* outText, tesseract::TessBaseAPI *api);
extern QString run(QString imagepath, tesseract::TessBaseAPI* api, QString &status, ETEXT_DESC *monitor);

#endif // IMAGEPROCESSOR_H
