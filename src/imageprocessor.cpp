#include "imageprocessor.h"
#include <leptonica/allheaders.h>
#include <tesseract/ocrclass.h>
#include <QString>
#include <QDebug>
#include <QStandardPaths>
#include <QImageWriter>
#include <QStringList>
#include <QTransform>
#include <QFile>
#include <QLineF>
#include <libexif/exif-data.h>

Pix* preprocess(Pix *image, int sX, int sY,
                int threshold, int mincount,
                int bgval, int smoothX,
                int smoothY, float scoreFract) {

    Pix* image_deskewed;
    Pix* image1;
    Pix* image2;
    Pix* image3;

    // If user selects previously preprocessed image (binarized aka 1 bpp), do nothing
    if(image->d != 32) {
        return image;
    }

    image1 = pixConvertRGBToGrayFast(image);
    image2 = pixUnsharpMaskingGray(image1, 5, 2.5);

    // pixOtsuThreshOnBackgroundNorm won't work if the internal pixGetBackgroundGrayMap
    // makes the map smaller than 5x5 (line 824 in adaptmap.c: (w + sx - 1) / sx) )
    l_float32 scaling_factor = 0;
    float width = (image2->w + sX - 1) / sX;
    float height = (image2->h + sY - 1) / sY;

    if(width < 5 || height < 5) {

        if (width < height) {
            scaling_factor = 6.0 * sX / image2->w;
        } else {
            scaling_factor = 6.0 * sY / image2->h;
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

QString writeToDisk(Pix *img) {

    l_uint8* ptr_memory;
    size_t len;
    pixWriteMemBmp(&ptr_memory, &len, img);

    QImage testimage;
    testimage.loadFromData((uchar *)ptr_memory, len);
    QString path(QStandardPaths::writableLocation(QStandardPaths::PicturesLocation) +
                 QString("/textractor_preprocessed.jpg"));
    testimage.save(path, "jpg", 100);
    delete ptr_memory;
    ptr_memory = NULL;
    return path;
}

QString clean(char* outText, tesseract::TessBaseAPI *api, int confidence) {

    QString text = QString::fromLocal8Bit(outText);

    // Lets do some cleaning based on the word confidence value
    QStringList results = text.split(" ");
    int *confidences = api->AllWordConfidences();
    int i = 0;

    while(i < results.size()) {
        if(confidences[i] < confidence) {
            results.removeAt(i);
        }
        ++i;
    }

    text = results.join(" ").toUtf8();

    delete [] confidences;
    delete [] outText;
    return text;
}

int getOrientation(char* imgPath)
{
    int orientation = 0;
    ExifData *exifData = exif_data_new_from_file(imgPath);

    if (exifData) {

        ExifByteOrder byteOrder = exif_data_get_byte_order(exifData);
        ExifEntry *exifEntry = exif_data_get_entry(exifData, EXIF_TAG_ORIENTATION);

        if (exifEntry) {
          orientation = exif_get_short(exifEntry->data, byteOrder);
        }

    exif_data_free(exifData);
    }

    return orientation;
}


QImage rotateByExif(int orientation, QImage img)
{
    QTransform transform;
    qDebug() << orientation;

    // Codes: http://www.impulseadventure.com/photo/exif-orientation.html
    // OK means that the rotation works correctly with images taken with Jolla's camera app
    // No comment means that the rotation is not tested

    switch(orientation) {
        case 1:
            break;                                        // OK

        case 2:
            img = img.mirrored(false, true);
            break;

        case 3:
            img = img.transformed(transform.rotate(180)); // OK
            break;

        case 4:
            img = img.mirrored(true, false);
            break;

        case 5:
            img = img.transformed(transform.rotate(90));
            img = img.mirrored(true, false);
            break;

        case 6:
            img = img.transformed(transform.rotate(90));  // OK
            break;

        case 7:
            img = img.transformed(transform.rotate(90));
            img = img.mirrored(false, true);
            break;

        case 8:
            // Jolla's camera app reports this orientation incorrectly
            // (as 1) so images taken upside down won't rotate correctly
            img = img.transformed(transform.rotate(90));
            break;

        default:
            break;
    }
    return img;
}

QString rotate(QString imagepath, Info &info) {

    QImage img(imagepath);
    img.setDotsPerMeterX(11811.025); // magic value :D = 300 dpi
    img.setDotsPerMeterY(11811.025);

    if(info.rotation != 0 && !info.gallery) {
        QTransform transform;
        img = img.transformed(transform.rotate(info.rotation));
    }

    if(info.gallery) {

        int orientation = getOrientation(imagepath.toLocal8Bit().data());

        if (orientation != 0) {
            img = rotateByExif(orientation, img);
        }

        imagepath = QStandardPaths::writableLocation(QStandardPaths::PicturesLocation) +
                    QString("/textractor_copy.jpg");
    }

    img.save(imagepath, "jpg", 100);
    return imagepath;
}

bool getCropPoints(QMap<QString, QPointF> &points, QMap<QString, QVariant> &cropPoints, QImage &img) {

    bool cropNeeded = false;
    // check if the points were moved
    foreach(QVariant corner, cropPoints) {

        QString key = cropPoints.key(corner);
        QPointF point = corner.toPointF();
        points.insert(key, point);

        int w = img.width() - 1;
        int h = img.height() - 1;

        if(key == "topLeft") {
            if (point.x() > 1 || point.y() > 1) {
                cropNeeded = true;
            }
        }

        if(key == "topRight") {
            if (point.x() < w || point.y() > 1) {
                cropNeeded = true;
            }
        }

        if(key == "bottomRight") {
            if (point.x() < w || point.y() < h ) {
                cropNeeded = true;
            }
        }

        if(key == "bottomLeft") {
            if (point.x() > 1 || point.y() < h) {
                cropNeeded = true;
            }
        }
    }
    return cropNeeded;
}

void crop(QString imagepath, Info &info)
{
    QImage img(imagepath);
    QMap<QString, QPointF> points;

    if(!getCropPoints(points, info.cropPoints, img)) {
        // crop not needed
        return;
    }

    qreal width = 0;
    qreal height = 0;

    // Calculate the size of the new image
    QLineF topLine(points.value("topLeft"), points.value("topRight"));
    QLineF bottomLine(points.value("bottomLeft"), points.value("bottomRight"));
    QLineF leftLine(points.value("topLeft"), points.value("bottomLeft"));
    QLineF rightLine(points.value("topRight"), points.value("bottomRight"));

    if(topLine.length() > bottomLine.length()) {
        width = topLine.length();
    } else {
        width = bottomLine.length();
    }

    if(topLine.length() > bottomLine.length()) {
        height = leftLine.length();
    } else {
        height = rightLine.length();
    }

    // Create the QPolygonF containing the corner points
    // in user specified quadrilateral arrangement
    QPolygonF fromPolygon;
    fromPolygon << points.value("topLeft");
    fromPolygon << points.value("topRight");
    fromPolygon << points.value("bottomRight");
    fromPolygon << points.value("bottomLeft");

    // target polygon
    QPolygonF toPolygon;
    toPolygon << QPointF(0, 0);
    toPolygon << QPointF(width, 0);
    toPolygon << QPointF(width, height);
    toPolygon << QPointF(0, height);

    QTransform transform;
    // crop matrix (actually perspective transform matrix)
    bool success = QTransform::quadToQuad(fromPolygon, toPolygon, transform);

    if (!success) {
        qDebug() << "Could not create the transformation matrix.";
        return;
    }

    // The resulting image has to be cropped by transferring the original
    // image top left, top right and bottom left coordinates
    // to the transformed image coordinates.
    // After this the crop offset can be calculated.
    QPoint tl = transform.map(QPoint(0, 0));
    QPoint bl = transform.map(QPoint(0, img.height()));
    QPoint tr = transform.map(QPoint(img.width(), 0));

    // execute the transform
    img = img.transformed(transform);

    int x;
    int y;

    if(-tl.x() > -bl.x()) {
        x = -tl.x();
    } else {
        x = -bl.x();
    }

    if(-tr.y() > -tl.y()) {
        y = -tr.y();
    } else {
        y = -tl.y();
    }

    // This is the top left coordinate of the crop area
    qDebug() << x << y;

    img = img.copy(x, y, width, height);
    img.save(imagepath, "jpg", 100);
}

QString run(QString imagepath,
            ETEXT_DESC* monitor,
            tesseract::TessBaseAPI* api,
            SettingsManager *settings,
            Info &info) {

    info.status = QString("Cropping...");
    Pix *pixs;

    crop(imagepath, info);

    char* path = imagepath.toLocal8Bit().data();
    pixs = pixRead(path);

    if(info.gallery) {
        QFile::remove(imagepath);
    }

    if(!pixs) {
        return QString("An error occured. Image could not be read.");
    }

    info.status = QString("Preprocessing the image...");
    pixs = preprocess(pixs, settings->getTileSize(), settings->getTileSize(),
                      settings->getThreshold(), settings->getMinCount(), settings->getBgVal(),
                      settings->getSmoothingFactor(), settings->getSmoothingFactor(),
                      settings->getScoreFract());



    if(!pixs) {
        pixDestroy(&pixs);
        return QString("An error occured. Image could not be preprocessed.");
    }

    info.prepdPath = writeToDisk(pixs);

    if(api->Init(NULL, settings->getLanguageCode().toLocal8Bit().data())) {
        qDebug() << "fail";
    }

    api->SetPageSegMode(tesseract::PSM_AUTO);
    api->SetImage(pixs);
    api->SetSourceResolution(300);

    char *outText;
    info.status = QString("Running OCR...");
    api->Recognize(monitor);
    outText = api->GetUTF8Text();

    info.status = QString("Postprocessing...");
    pixDestroy(&pixs);

    QString text = clean(outText, api, settings->getConfidence());
    api->Clear();
    return text;
}

QString runPDF(PDFHandler* pdf,
               ETEXT_DESC* monitor,
               tesseract::TessBaseAPI* api,
               SettingsManager *settings,
               Info &info) {

    QString text;
    info.curPage = 1;

    foreach(int pageNumber, info.pages) {

        info.status = QString("Converting page %1/%2 to image...").arg(info.curPage).arg(info.pages.length());

        Pix* pageimg = pdf->getPixFromPage(pageNumber);

        if(!pageimg) {
            continue;
        }

        info.status = QString("Preprocessing page %1/%2...").arg(info.curPage).arg(info.pages.length());

        Pix *pixs = preprocess(pageimg, settings->getTileSize(), settings->getTileSize(),
                               settings->getThreshold(), settings->getMinCount(), settings->getBgVal(),
                               settings->getSmoothingFactor(), settings->getSmoothingFactor(),
                               settings->getScoreFract());

        if(!pixs) {
            pixDestroy(&pixs);
            continue;
        }

        info.prepdPath = writeToDisk(pixs);

        if(api->Init(NULL, settings->getLanguageCode().toLocal8Bit().data())) {
            qDebug() << "fail";
        }

        api->SetPageSegMode(tesseract::PSM_AUTO);
        api->SetImage(pixs);
        api->SetSourceResolution(300);

        char *outText;
        info.status = QString("Running OCR for page %1/%2...").arg(info.curPage).arg(info.pages.length());
        api->Recognize(monitor);
        outText = api->GetUTF8Text();

        info.status = QString("Postprocessing page %1/%2...").arg(info.curPage).arg(info.pages.length());
        pixDestroy(&pixs);

        text += clean(outText, api, settings->getConfidence());
        text += "\r\n";

        ++info.curPage;
        monitor->progress = 0;
    }

    api->Clear();
    return text;
}
