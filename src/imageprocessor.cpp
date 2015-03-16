#include "imageprocessor.h"
#include <leptonica/allheaders.h>
#include <tesseract/ocrclass.h>
#include <QString>
#include <QDebug>
#include <QStandardPaths>
#include <QImageWriter>
#include <QImage>
#include <QStringList>

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
    // qDebug() << "converted to gray";
    // unsharp mask
    image = pixUnsharpMaskingGray(image, usm_halfwidth, usm_fract);
    // qDebug() << "unsharp mask";
    // adaptive treshold
    if(pixOtsuAdaptiveThreshold(image, sX, sY, smoothX, smoothY, scoreFract, NULL, &image) != 0) {
        return NULL;
    }
    // qDebug() << "adaptive treshold";
    return image;
}

extern QString run(QString imagepath, tesseract::TessBaseAPI *api, QString &status, ETEXT_DESC* monitor) {

    status = QString("Initializing...");
    PIX *pixs;

    QImage img(imagepath);
    img.setDotsPerMeterX(11811.025); // magic value :D = 300 dpi
    img.setDotsPerMeterY(11811.025);
    img.scaled(img.width() / 2, img.height() / 2, Qt::KeepAspectRatio);
    img.save(imagepath, "jpg", 100);

    char* path = imagepath.toLocal8Bit().data();
    pixs = pixRead(path);

    status = QString("Preprocessing the image...");
    pixs = preprocess(pixs, 5, 2.0, 200, 200, 0, 0, 0.0);

    /*
     * Enable this to see the preprocessed image
     *
    l_uint8* ptr_memory;
    size_t len;
    pixWriteMemBmp(&ptr_memory, &len, pixs);
    qDebug() << "wrote to mem";

    QImage testimage;
    testimage.loadFromData((uchar *)ptr_memory, len);
    qDebug() << "loaded image from mem";
    testimage.save(QStandardPaths::writableLocation(QStandardPaths::DataLocation) + QString("/test2.jpg"), "jpg", 100);
    qDebug() << "saved to disk";
    */

    api->Init(NULL, "eng");
    api->SetImage(pixs);
    api->SetSourceResolution(300);

    char *outText;
    status = QString("Running OCR...");
    api->Recognize(monitor);
    outText = api->GetUTF8Text();

    status = QString("Postprocessing...");

    QString text = QString::fromLocal8Bit(outText);

    // Lets do some cleaning based on the word confidence value
    QStringList results = text.split(" ");
    int *confidences = api->AllWordConfidences();
    int i = 0;

    while(i < results.size()) {
        if(confidences[i] < 20) {
            results.removeAt(i);
        }
        ++i;
    }

    text = results.join(" ");

    delete [] confidences;
    delete [] outText;
    pixDestroy(&pixs);
    return text.toUtf8();
}
