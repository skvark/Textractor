import QtQuick 2.1
import Sailfish.Silica 1.0
import QtMultimedia 5.0
import QtSensors 5.0
import harbour.textractor.cameramodecontrol 1.0


Page {
    id: root

    allowedOrientations: Orientation.All

    Component.onCompleted: {
        root._clickablePageIndicators = false
        internal.complete = true
    }

    Component.onDestruction: {
        if(Camera.UnloadedState != camera.cameraState) {
            camera.cameraState = Camera.UnloadedState
        }
    }

    QtObject {
        id: internal

        property bool complete: false
        property bool unload: false

        function reload() {
            if(complete) {
                unload = true;
            }
        }
    }

    Item {
        id: viewfinderClip
        anchors.fill: parent
        clip: true

        VideoOutput {

            id: viewfinder
            property bool mirror: cameraModeControl.device == "secondary"
            anchors.centerIn: parent

            height: root.isPortrait ? root.height : root.width
            width: root.isPortrait ? root.width : root.height

            visible: !imagePreview.visible

            rotation: -root.rotation
            scale: contentRect.width / contentRect.height < width / height
                   ? width / contentRect.width : height / contentRect.height

            source: camera

        }
    }

    Image {
        id: imagePreview

        anchors.fill: parent

        visible: Image.Ready == status

        fillMode: Image.PreserveAspectFit
        smooth: true
    }

    CameraModeControl {
        id: cameraModeControl
        camera: camera
        onDeviceChanged: {
            internal.reload()
        }
    }

    Timer {
        id: reloadTimer
        interval: 10
        running: internal.unload && Camera.UnloadedStatus == camera.cameraStatus

        onTriggered: {
            internal.unload = false
        }
    }

    Camera {
        id: camera

        captureMode: Camera.CaptureStillImage
        cameraState: internal.complete && !internal.unload ? Camera.ActiveState : Camera.UnloadedState

        exposure.exposureMode: Camera.ExposureAuto

        focus.focusMode: Camera.FocusContinuous
        focus.focusPointMode: Camera.FocusPointAuto

        flash.mode: Camera.FlashOff

        imageCapture {
            resolution: "primary" == cameraModeControl.device
                        ? cameraModeControl.primaryResolution : cameraModeControl.secondaryResolution

            onImageCaptured: {
                imagePreview.source = preview
            }

            onImageSaved: {
                tesseractAPI.analyze(path, picRotation, false);
                pageStack.push(Qt.resolvedUrl("ResultsPage.qml"), { loading: true })
            }
        }

        onCameraStatusChanged: {
            if(Camera.LoadedStatus == cameraStatus) {
                camera.exposure.setAutoAperture()
                camera.exposure.setAutoIsoSensitivity()
                camera.exposure.setAutoShutterSpeed()
            }
        }
    }

    OrientationSensor {
        id: sensor
        active: true
        property int rotationAngle: _getOrientation(reading.orientation)
        function _getOrientation(value) {
            switch (value) {
            case 1:
                return 90
            case 2:
                return -90
            case 3:
                return 180
            case 4:
                return 0
            default:
                return 0
            }
        }
    }

    property int picRotation;

    IconButton {
        id: captureButton

        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.rightMargin: root.isLandscape ? 0 : (Screen.width / 2 - width / 2)

        enabled: Camera.ActiveState == camera.cameraState && Camera.ActiveStatus == camera.cameraStatus

        icon.source: "image://theme/icon-camera-shutter-release"

        onClicked: {
            picRotation = sensor.rotationAngle;
            camera.imageCapture.capture();
        }
    }
}
