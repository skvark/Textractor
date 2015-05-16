#include "imageprocessor.h"
#include <leptonica/allheaders.h>
#include <tesseract/ocrclass.h>
#include <QString>
#include <QDebug>
#include <QStandardPaths>
#include <QImageWriter>
#include <QImage>
#include <QStringList>
#include <QTransform>

Pix* preprocess(Pix *image, int sX, int sY, int smoothX, int smoothY, float scoreFract) {

    image = pixConvertRGBToGrayFast(image);
    image = pixUnsharpMaskingGray(image, 5, 2.5);
    l_int32 pthresh;
    image = pixOtsuThreshOnBackgroundNorm(image, NULL, sX, sY, smoothX, smoothY, 100, 50, 255, scoreFract, &pthresh);
    l_float32 angle;
    Pix* image_deskewed;
    image_deskewed = pixFindSkewAndDeskew(image, 1, &angle, NULL);
    if(image_deskewed != NULL) {
        pixDestroy(&image);
        return image_deskewed;
    }
    return image;

}

void writeToDisk(Pix *img) {

    l_uint8* ptr_memory;
    size_t len;
    pixWriteMemBmp(&ptr_memory, &len, img);

    QImage testimage;
    testimage.loadFromData((uchar *)ptr_memory, len);
    testimage.save(QStandardPaths::writableLocation(QStandardPaths::PicturesLocation) +
                   QString("/textractor_preprocessed.jpg"), "jpg", 100);
}

QString clean(char* outText, tesseract::TessBaseAPI *api) {

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

    text = results.join(" ").toUtf8();

    delete [] confidences;
    delete [] outText;
    return text;
}

QString run(QString imagepath,
            tesseract::TessBaseAPI *api,
            ETEXT_DESC* monitor,
            SettingsManager *settings,
            QPair<QString, int> &info) {

    info.first = QString("Initializing...");
    Pix *pixs;

    QImage img(imagepath);
    img.setDotsPerMeterX(11811.025); // magic value :D = 300 dpi
    img.setDotsPerMeterY(11811.025);
    QTransform transform;
    img = img.transformed(transform.rotate(info.second));
    // if scaled up, the image will take a lot of space and OCR becomes really slow
    //img = img.scaled(img.width() / 2, img.height() / 2, Qt::KeepAspectRatio);
    img.save(imagepath, "jpg", 100);

    char* path = imagepath.toLocal8Bit().data();
    pixs = pixRead(path);

    info.first = QString("Preprocessing the image...");
    pixs = preprocess(pixs, 200, 200, 0, 0, 0.09);

    writeToDisk(pixs);

    if(api->Init(NULL, settings->getLanguageCode().toLocal8Bit().data())) {
        qDebug() << "fail";
    }
    api->SetPageSegMode(tesseract::PSM_AUTO);
    api->SetImage(pixs);
    api->SetSourceResolution(300);

    char *outText;
    info.first = QString("Running OCR...");
    api->Recognize(monitor);
    outText = api->GetUTF8Text();

    info.first = QString("Postprocessing...");
    pixDestroy(&pixs);

    QString text = clean(outText, api);
    api->Clear();
    return text;
}
