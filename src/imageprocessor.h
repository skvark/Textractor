#ifndef IMAGEPROCESSOR_H
#define IMAGEPROCESSOR_H

#include <tesseract/baseapi.h>
#include <QString>

extern Pix *preprocess(Pix *image,
                       int usm_halfwidth,
                       float usm_fract,
                       int sX,
                       int sY,
                       int smoothX,
                       int smoothY,
                       float scoreFract);

extern QString run(QString imagepath, tesseract::TessBaseAPI* api);

#endif // IMAGEPROCESSOR_H
