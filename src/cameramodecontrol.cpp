#include "CameraModeControl.h"

#include <QMediaObject>
#include <QMediaService>
#include <QVideoDeviceSelectorControl>

#include <QDebug>

#ifdef PF_PLATFORM_OS_SAILFISH

#include <mlite5/MGConfItem>

#endif

CameraModeControl::CameraModeControl(QObject *parent): QObject(parent)
    , m_camera(nullptr)
    , m_device("primary")
#ifdef PF_PLATFORM_OS_SAILFISH
    , m_primaryResolutionConf(new MGConfItem("/apps/jolla-camera/primary/image/imageResolution", this))
    , m_secondaryResolutionConf(new MGConfItem("/apps/jolla-camera/secondary/image/imageResolution", this))
#endif
{
#ifdef PF_PLATFORM_OS_SAILFISH
    QObject::connect(m_primaryResolutionConf, SIGNAL(valueChanged()), this, SIGNAL(primaryResolutionChanged()));
    QObject::connect(m_secondaryResolutionConf, SIGNAL(valueChanged()), this, SIGNAL(secondaryResolutionChanged()));
#endif
}

QObject* CameraModeControl::camera() const
{
    return m_camera;
}

QString CameraModeControl::device() const
{
    return m_device;
}

QString CameraModeControl::primaryResolution() const
{
#ifdef PF_PLATFORM_OS_SAILFISH
    const QString resolution = m_primaryResolutionConf->value().toString();
    return resolution.isEmpty() ? "0x0" : resolution;
#else
    return "0x0";
#endif
}

QString CameraModeControl::secondaryResolution() const
{
#ifdef PF_PLATFORM_OS_SAILFISH
    const QString resolution = m_secondaryResolutionConf->value().toString();
    return resolution.isEmpty() ? "0x0" : resolution;
#else
    return "0x0";
#endif
}

void CameraModeControl::setCamera(QObject *const &camera)
{
    if(camera != m_camera)
    {
        m_camera = camera;

        emit cameraChanged(m_camera);
    }
}

void CameraModeControl::setDevice(const QString &device)
{
    if(device != m_device)
    {
        m_device = device;

        if(m_camera)
        {
            QMediaObject *mediaObject =
                    m_camera ? qobject_cast<QMediaObject *>(m_camera->property("mediaObject").value<QObject*>())
                             : nullptr;

            if(mediaObject)
            {
                QVideoDeviceSelectorControl *videoDevice =
                        mediaObject->service()->requestControl<QVideoDeviceSelectorControl*>();

                if(videoDevice)
                {
                    const int value = ("primary" == device) ? 0 : 1;

                    if(videoDevice->selectedDevice() != value)
                    {
                        videoDevice->setSelectedDevice(value);
                    }
                }
            }
        }

        emit deviceChanged(m_device);
    }
}
