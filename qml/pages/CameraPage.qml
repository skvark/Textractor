import QtQuick 2.1
import Sailfish.Silica 1.0
import QtMultimedia 5.0
import QtSensors 5.0
import harbour.textractor.cameramodecontrol 1.0


Page {
    id: root

    property bool cropReady: false;
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

    onStatusChanged: {
        if (status === PageStatus.Activating && internal.complete && !cropReady) {
            camera.cameraState = Camera.ActiveState;
        }
        if (status === PageStatus.Active && cropReady) {
            cropReady = false;
            backNavigation = true;
            pageStack.push(Qt.resolvedUrl("ResultsPage.qml"), { loading: true });
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

        BusyIndicator {
            id: busyind
            anchors.centerIn: parent
            size: BusyIndicatorSize.Large
            running: cropReady;
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

    onPageContainerChanged: {

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
                camera.cameraState = Camera.UnloadedState

                if(orientationModes[orientationMode] === "auto") {
                    tesseractAPI.prepareForCropping(path, picRotation, false);
                } else {
                    if(orientationModes[orientationMode] === "landscape") {
                        // landscape is the default orientation
                        tesseractAPI.prepareForCropping(path, 0, false);
                    } else if (orientationModes[orientationMode] === "portrait") {
                        // top edge of the device is pointing up, rotate the image 90 degrees clockwise
                        tesseractAPI.prepareForCropping(path, 90, false);
                    }
                }
                var dialog = pageStack.push(Qt.resolvedUrl("CroppingPage.qml"), { loading: true });
                dialog.accepted.connect(function() {
                    root.backNavigation = false;
                    cropReady = true;
                });
            }
        }

        onCameraStatusChanged: {
            if(Camera.LoadedStatus == cameraStatus) {
                camera.exposure.setAutoAperture()
                if(!auto) {
                    camera.exposure.manualShutterSpeed = shutterSpeed;
                    camera.exposure.manualIso = iso;
                } else {
                    camera.exposure.setAutoIsoSensitivity()
                    camera.exposure.setAutoShutterSpeed()
                }
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
    property int orientationMode: 0;
    property bool auto: true;
    property var orientationModes: ["auto", "landscape", "portrait"];
    property string mode: "";
    property real shutterSpeed: -1;
    property int isoSpeed: -1;
    property int shutterIndex: 0;
    property int isoIndex: 0;

    Rectangle {
        anchors.fill: manualButton
        radius: 10;
        color: Theme.rgba(Theme.highlightBackgroundColor, 0.1)
    }

    BackgroundItem {

        id: manualButton
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.left: parent.left
        width: parent.width
        height: captureButton.height
        enabled: Camera.ActiveState == camera.cameraState && Camera.ActiveStatus == camera.cameraStatus
        anchors.topMargin: 20
        anchors.leftMargin: 30
        anchors.rightMargin: 30

        Text {
            text: if(auto) {
                      "Camera mode: automatic";
                  } else {
                      "Camera mode: " + mode;
                  }

            anchors.left: parent.left
            height: parent.height
            verticalAlignment: Text.AlignVCenter
            anchors.leftMargin: 20
            anchors.rightMargin: 20
            color: Theme.primaryColor
            font.pixelSize: Theme.fontSizeExtraSmall
        }

        onClicked: {
            var dialog = pageStack.push(Qt.resolvedUrl("CameraModePage.qml"), {iso: isoIndex, shutter: shutterIndex});
            dialog.accepted.connect(function() {
                if(dialog.shutter !== 0 || dialog.iso !== 0) {
                    auto = false;
                    mode = dialog.shutterSpeedsStr[dialog.shutter] + " s, ISO " + dialog.isoSpeedsStr[dialog.iso];
                    shutterSpeed = dialog.shutterSpeeds[dialog.shutter];
                    isoSpeed = dialog.isoSpeeds[dialog.iso];
                    shutterIndex = dialog.shutter;
                    isoIndex = dialog.iso;
                    camera.exposure.manualShutterSpeed = shutterSpeed;
                    camera.exposure.manualIso = isoSpeed;
                } else {
                    auto = true;
                }
            });
        }
    }

    IconButton {
        id: captureButton

        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.rightMargin: root.isLandscape ? 20 : (Screen.width / 3 - width / 3)
        anchors.bottomMargin: 20

        enabled: Camera.ActiveState == camera.cameraState && Camera.ActiveStatus == camera.cameraStatus

        icon.source: "image://theme/icon-camera-shutter-release"

        onClicked: {
            console.log(camera.exposure.shutterSpeed);
            console.log(camera.exposure.iso);
            picRotation = sensor.rotationAngle;
            camera.imageCapture.capture();
        }
    }

    IconButton {

        id: orientationButton
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        width: 200
        height: captureButton.height
        anchors.rightMargin: root.isLandscape ? (Screen.width / 2 - width / 2) + 100 : Screen.width - 150
        enabled: Camera.ActiveState == camera.cameraState && Camera.ActiveStatus == camera.cameraStatus
        anchors.bottomMargin: 20

        icon.source: if(orientationModes[orientationMode] !== "auto") {
                        return "image://theme/icon-camera-backcamera"
                     } else {
                        return "image://theme/icon-camera-automatic"
                     }

        icon.scale: if(orientationModes[orientationMode] === "auto") {
                        return 0.5;
                     } else {
                        return 1.0;
                    }

        icon.rotation: if(orientationModes[orientationMode] === "landscape") {
                          return -90;
                       } else {
                           return 0;
                       }

        icon.anchors.left: orientationButton.left

        Text {
            text: "Orientation: " + orientationModes[orientationMode];
            anchors.left: parent.left
            height: parent.height
            verticalAlignment: Text.AlignVCenter
            anchors.leftMargin: 130
            color: Theme.primaryColor
            font.pixelSize: Theme.fontSizeExtraSmall
        }

        onClicked: {
            ++orientationMode;
            if(orientationMode > 2) {
                orientationMode = 0;
            }
        }
    }

    Connections {
        target: Qt.application
        onActiveChanged:
            if(!Qt.application.active) {
                camera.cameraState = Camera.UnloadedState;
            } else if (Qt.application.active) {
                camera.cameraState = Camera.ActiveState;
            }
    }
}
