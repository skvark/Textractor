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

Pix* preprocess(Pix *image, int sX, int sY,
                int threshold, int mincount,
                int bgval, int smoothX,
                int smoothY, float scoreFract) {

    Pix* image_deskewed;
    Pix* image1;
    Pix* image2;
    Pix* image3;

    image1 = pixConvertRGBToGrayFast(image);
    image2 = pixUnsharpMaskingGray(image1, 5, 2.5);

    // pixOtsuThreshOnBackgroundNorm won't work if the internal pixGetBackgroundGrayMap
    // makes the map smaller than 5x5 (line 824 in adaptmap.c: (w + sx - 1) / sx) )
    l_float32 scaling_factor = 0;
    float width = (image2->w + sX - 1) / sX;
    float height = (image2->h + sY - 1) / sY;

    if(width < 5 || height < 5) {

        if (width < height) {
            scaling_factor = 5.1 / width;
        } else {
            scaling_factor = 5.1 / height;
        }
        image2 = pixScaleGrayLI(image2, scaling_factor, scaling_factor);

    }

    l_int32 pthresh;
    image3 = pixOtsuThreshOnBackgroundNorm(image2, NULL, sX, sY,
                                           threshold, mincount, bgval,
                                           smoothX, smoothY,
                                           scoreFract, &pthresh);

    l_float32 angle;
    image_deskewed = pixFindSkewAndDeskew(image3, 1, &angle, NULL);

    if(image_deskewed != NULL) {
        pixDestroy(&image);
        pixDestroy(&image1);
        pixDestroy(&image2);
        pixDestroy(&image3);
        return image_deskewed;
    }

    pixDestroy(&image);
    pixDestroy(&image1);
    pixDestroy(&image2);
    return image3;

}

void writeToDisk(Pix *img) {

    l_uint8* ptr_memory;
    size_t len;
    pixWriteMemBmp(&ptr_memory, &len, img);

    QImage testimage;
    testimage.loadFromData((uchar *)ptr_memory, len);
    testimage.save(QStandardPaths::writableLocation(QStandardPaths::PicturesLocation) +
                   QString("/textractor_preprocessed.jpg"), "jpg", 100);
    delete ptr_memory;
    ptr_memory = NULL;

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
            ETEXT_DESC* monitor,
            tesseract::TessBaseAPI* api,
            SettingsManager *settings,
            QPair<QString, int> &info) {

    info.first = QString("Initializing...");
    Pix *pixs;

    QImage img(imagepath);
    img.setDotsPerMeterX(11811.025); // magic value :D = 300 dpi
    img.setDotsPerMeterY(11811.025);

    if(info.second != 0) {
        QTransform transform;
        img = img.transformed(transform.rotate(info.second));
    }

    imagepath = QStandardPaths::writableLocation(QStandardPaths::PicturesLocation) +
                QString("/textractor_copy.jpg");

    // if scaled up, the image will take a lot of space and OCR becomes really slow
    //img = img.scaled(img.width() / 2, img.height() / 2, Qt::KeepAspectRatio);
    img.save(imagepath, "jpg", 100);

    char* path = imagepath.toLocal8Bit().data();
    pixs = pixRead(path);

    if(!pixs) {
        return QString("An error occured. Image could not be read.");
    }

    info.first = QString("Preprocessing the image...");
    pixs = preprocess(pixs, settings->getTileSize(), settings->getTileSize(),
                      settings->getThreshold(), settings->getMinCount(), settings->getBgVal(),
                      settings->getSmoothingFactor(), settings->getSmoothingFactor(),
                      settings->getScoreFract());

    if(!pixs) {
        pixDestroy(&pixs);
        return QString("An error occured. Image could not be preprocessed.");
    }


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
