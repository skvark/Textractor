#ifndef PDFHANDLER_H
#define PDFHANDLER_H

#include <QObject>
#include <leptonica/allheaders.h>
#include <poppler/qt5/poppler-qt5.h>
#include "PDFThumbnailProvider.h"
#include <QStringList>


class PDFHandler : public QObject
{
    Q_OBJECT
public:
    explicit PDFHandler(QObject *parent = 0);
    ~PDFHandler();

    void loadFile(QString filename);
    Pix *getPixFromPage(int pageNumber);
    PDFThumbnailProvider *getThumbnailProvider();
    QStringList getThumbnails(QString path, QString &status);
    QStringList getIds();


signals:
    void thumbnailsReady(QStringList ids);

public slots:

private:

    Poppler::Document* document_;
    PDFThumbnailProvider* thumbnailProvider_;
    QStringList ids_;

};

#endif // PDFHANDLER_H
