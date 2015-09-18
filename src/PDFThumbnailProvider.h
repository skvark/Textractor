#ifndef PDFTHUMBNAILPROVIDER_H
#define PDFTHUMBNAILPROVIDER_H

#include <qquickimageprovider.h>
#include <QMap>
#include <qdebug.h>

class PDFThumbnailProvider : public QQuickImageProvider
{
public:
    PDFThumbnailProvider();

    QPixmap requestPixmap(const QString & id, QSize * size, const QSize & requestedSize)
    {
        Q_UNUSED(size);
        Q_UNUSED(requestedSize);
        return QPixmap::fromImage(thumbnails_.value(id));
    }

    void clear();
    void addImage(QString id, const QImage img);

private:
    QMap<QString, QImage> thumbnails_;

};

#endif // PDFTHUMBNAILPROVIDER_H
