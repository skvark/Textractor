#include "PDFThumbnailProvider.h"


PDFThumbnailProvider::PDFThumbnailProvider() : QQuickImageProvider(QQuickImageProvider::Pixmap)
{
}

void PDFThumbnailProvider::addImage(QString id, const QImage img) {
    thumbnails_.insert(id, img);
}

void PDFThumbnailProvider::clear() {
    thumbnails_.clear();
}
