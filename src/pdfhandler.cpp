#include "pdfhandler.h"
#include <poppler/qt5/poppler-qt5.h>
#include <QBuffer>
#include <QImage>
#include <QDebug>

PDFHandler::PDFHandler(QObject *parent) :
    QObject(parent)
{
    thumbnailProvider_ = new PDFThumbnailProvider();
}

PDFHandler::~PDFHandler()
{
    if(document_) {
        delete document_;
        document_ = 0;
    }
    delete thumbnailProvider_;
    thumbnailProvider_ = 0;
}

void PDFHandler::loadFile(QString filename)
{
    Poppler::Document* document = Poppler::Document::load(filename);
    if (!document || document->isLocked()) {
      delete document;
      return;
    }
    document_ = document;
}

Pix *PDFHandler::getPixFromPage(int pageNumber)
{
    if (document_ == 0) {
      return nullptr;
    }

    Poppler::Page* pdfPage = document_->page(pageNumber);
    if (pdfPage == 0) {
      return nullptr;
    }

    QImage image = pdfPage->renderToImage(300, 300);
    if (image.isNull()) {
      return nullptr;
    }

    QByteArray data;
    QBuffer buffer(&data);
    buffer.open(QIODevice::WriteOnly);
    image.save(&buffer, "jpg", 100);
    unsigned char* memdata = (unsigned char*)buffer.buffer().data();
    Pix* img = pixReadMem(memdata, buffer.buffer().size());

    delete pdfPage;

    return img;
}

PDFThumbnailProvider *PDFHandler::getThumbnailProvider()
{
    return thumbnailProvider_;
}

QStringList PDFHandler::getThumbnails(QString path, QString& status)
{
    loadFile(path);
    ids_.clear();
    thumbnailProvider_->clear();
    for(int i = 0; i < document_->numPages(); ++i) {

        status = QString::number(i + 1) + QString(" / ") + QString::number(document_->numPages());

        float size;

        if(document_->page(i)->pageSizeF().width() < document_->page(i)->pageSizeF().height()) {
            size = document_->page(i)->pageSizeF().width();
        } else {
            size = document_->page(i)->pageSizeF().height();
        }

        float dpi = 340.0 / (size / 72.0);
        thumbnailProvider_->addImage(QString::number(i), document_->page(i)->renderToImage(dpi, dpi));
        ids_.append(QString::number(i));
    }
    return ids_;
}

QStringList PDFHandler::getIds()
{
    return ids_;
}






