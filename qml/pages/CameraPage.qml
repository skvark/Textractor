import QtQuick 2.0
import Sailfish.Silica 1.0
import QtMultimedia 5.0
import QtSensors 5.0

Page {
    id: page

    SilicaListView {

        anchors.fill: parent

        Item {
            id: cameraOutput
            x: 0
            y: 0
            anchors.fill: parent
            width: 540
            height: 960

            Camera {
                id: camera
                captureMode: Camera.CaptureStillImage

                focus {
                    focusMode: Camera.FocusContinuous
                    focusPointMode: Camera.FocusPointCenter
                }

                flash.mode: Camera.FlashOff

                imageProcessing {
                    sharpeningLevel: 1
                }

                exposure {
                    exposureMode: Camera.ExposurePortrait
                }

            }

            VideoOutput {
               id: videoPreview
               source: camera
               width: page.width
               height: page.height
               anchors.fill: parent
               fillMode: VideoOutput.PreserveAspectFit
           }
        }

        Row {

            anchors {
                bottom: parent.bottom
                bottomMargin: Theme.paddingMedium
                horizontalCenter: parent.horizontalCenter
            }

            IconButton {

                id: cameraButton
                width: page.width / 3
                icon.source: "image://theme/icon-camera-shutter-release"
                scale: 1.5
                onClicked: {
                    picRotation = sensor.rotationAngle;
                    camera.imageCapture.capture();
                }
            }
            z: 30
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
                return 270
            case 4:
                return 0
            default:
                return -1
            }
        }
    }

    property int picRotation;

    Connections {
        target: camera.imageCapture
        onImageSaved: {
            camera.cameraState = Camera.UnloadedState
            tesseractAPI.analyze(path, picRotation);
            pageStack.push(Qt.resolvedUrl("ResultsPage.qml"), { loading: true })
        }
    }

    Connections {
        target: tesseractAPI
        onAnalyzed: {
            camera.cameraState = Camera.ActiveState
        }
    }

}


