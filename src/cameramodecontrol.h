#ifndef CAMERAMODECONTROL_H
#define CAMERAMODECONTROL_H

#include <QObject>

#ifdef PF_PLATFORM_OS_SAILFISH
class MGConfItem;
#endif

class CameraModeControl: public QObject
{
    Q_OBJECT

    Q_PROPERTY(
        QObject*        camera
        READ            camera
        WRITE           setCamera
        NOTIFY          cameraChanged
    )

    Q_PROPERTY(
        QString         device
        READ            device
        WRITE           setDevice
        NOTIFY          deviceChanged
    )

    Q_PROPERTY(
        QString         primaryResolution
        READ            primaryResolution
        NOTIFY          primaryResolutionChanged
    )

    Q_PROPERTY(
        QString         secondaryResolution
        READ            secondaryResolution
        NOTIFY          secondaryResolutionChanged
    )

public:
    explicit            CameraModeControl(QObject *parent = 0);

    QObject*            camera() const;
    QString             device() const;
    QString             primaryResolution() const;
    QString             secondaryResolution() const;

    void                setCamera(QObject *const &camera);
    void                setDevice(const QString &device);

signals:
    void                cameraChanged(QObject *const &camera);
    void                deviceChanged(const QString &device);
    void                primaryResolutionChanged();
    void                secondaryResolutionChanged();

private:
    QObject *m_camera;
    QString m_device;

#ifdef PF_PLATFORM_OS_SAILFISH
    MGConfItem         *m_primaryResolutionConf;
    MGConfItem         *m_secondaryResolutionConf;
#endif

};

#endif // CAMERAMODECONTROL_H
