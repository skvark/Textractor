#include "imageprocessor.h"
#include <leptonica/allheaders.h>
#include <QString>
#include <QDebug>
#include <QStandardPaths>
#include <QImageWriter>
#include <QImage>

extern Pix* preprocess(Pix *image,
                       int usm_halfwidth,
                       float usm_fract,
                       int sX,
                       int sY,
                       int smoothX,
                       int smoothY,
                       float scoreFract) {

    // convert the 32 bpp image to gray and 8 bpp (leptonica requires 8 bpp)
    image = pixConvertRGBToGrayFast(image);
    // unsharp mask
    image = pixUnsharpMaskingGray(image, usm_halfwidth, usm_fract);
    // adaptive treshold
    if(pixOtsuAdaptiveThreshold(image, sX, sY, smoothX, smoothY, scoreFract, NULL, &image) != 0) {
        return NULL;
    }
    return image;
}

extern QString run(QString imagepath, tesseract::TessBaseAPI* api) {

    PIX *pixs;
    QString new_path = QStandardPaths::writableLocation(QStandardPaths::PicturesLocation) + QString("/test.tif");

    QImage img(imagepath);
    img.setDotsPerMeterX(11811.025); // magic value :D = 300 dpi
    img.setDotsPerMeterY(11811.025);
    img.save(new_path, "tiff", 100);

    char* path = new_path.toLocal8Bit().data();
    pixs = pixRead(path);
    pixs = preprocess(pixs, 5, 2.5, 2000, 2000, 0, 0, 0.0);

    l_uint8* ptr_memory;
    size_t len;
    pixWriteMemBmp(&ptr_memory, &len, pixs);

    QImage testimage;
    testimage.loadFromData((uchar *)ptr_memory, len);
    testimage.save(QStandardPaths::writableLocation(QStandardPaths::PicturesLocation) + QString("/test2.tif"), "tiff", 100);

    api->Init(NULL, "eng");
    api->SetImage(pixs);
    // Get OCR result
    char *outText;
    outText = api->GetUTF8Text();

    qDebug() << outText;

    QString text = QString::fromLocal8Bit(outText);
    delete [] outText;
    pixDestroy(&pixs);
    return text;
}
