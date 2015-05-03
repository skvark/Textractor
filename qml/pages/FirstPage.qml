import QtQuick 2.0
import Sailfish.Silica 1.0
import QtMultimedia 5.0

Page {
    id: page

    SilicaListView {

        anchors.fill: parent
        header: Component {

            PageHeader {
                title: "Take a Picture of Text"
                height: 140

                SectionHeader {
                    id: section
                    text: "To get best results see hints page."
                    anchors.top: parent.top
                    anchors.topMargin: 60
                }
            }
        }

        PullDownMenu {

            MenuItem {
                text: qsTr("Settings");
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("Settings.qml"))
                }
            }

            MenuItem {
                text: qsTr("Usage Hints");
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("HintsPage.qml"))
                }
            }
        }

        Item {
            id: cameraOutput
            x: 0
            y: 0
            anchors.fill: parent
            width: 540
            height: 960

            Camera {
                id: camera

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
               width: 540
               anchors.centerIn: parent
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
                    camera.imageCapture.capture();
                }
            }
            z: 30
        }
    }

    Connections {
        target: camera.imageCapture
        onImageSaved: {
            camera.cameraState = Camera.UnloadedState
            tesseractAPI.analyze(path);
            pageStack.push(Qt.resolvedUrl("SecondPage.qml"), { loading: true })
        }
    }

    Connections {
        target: tesseractAPI
        onAnalyzed: {
            camera.cameraState = Camera.ActiveState
        }
    }

}


