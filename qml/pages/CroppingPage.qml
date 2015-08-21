import QtQuick 2.0
import Sailfish.Silica 1.0

Dialog {

    id: cropDialog
    property bool loading;
    property var cropPoints: {"topLeft": Qt.point(0, 0)};
    property string curPoint: "";

    Component.onCompleted: {
        curPoint = topLeft.objectName
    }

    DialogHeader {
       id: header
       acceptText: "Analyze"
       cancelText: "Cancel"
    }

    onAccepted: {
        tesseractAPI.analyze(cropView.source, cropPoints);
    }

    SilicaFlickable {

        id: container
        anchors.top: header.bottom;
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: Theme.paddingLarge
        anchors.rightMargin: Theme.paddingLarge

        Rectangle {
            id: mask
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.leftMargin: 540 / 2 - width / 2
            anchors.topMargin: -zoomArea.height - Theme.paddingLarge
            width: zoomArea.width
            height: zoomArea.height
            border.width: 1
            border.color: Theme.secondaryHighlightColor
            clip: true
            color: Theme.secondaryColor
        }

        Item {

            id: zoomArea
            width: 110
            height: 110
            anchors.fill: mask
            clip: true

            Image {
                id: zoom
                cache: false
                width: 5 * cropView.paintedWidth
                height: 5 * cropView.paintedHeight
                x: 0
                y: 0
                source: cropView.source
            }

            Image {
                id: crosshair
                anchors.fill: parent
                source: "../images/circular218.png"
            }

        }

        BusyIndicator {
            id: busyind
            anchors.centerIn: parent
            size: BusyIndicatorSize.Large
            anchors.verticalCenterOffset: 300
            running: true;
        }

        ViewPlaceholder {
            id: pholder
            anchors.centerIn: parent
            anchors.verticalCenterOffset: 450
            enabled: loading
            text: qsTr("Preparing image...")
        }

        Label {
            id: info
            width: parent.width
            wrapMode: Text.Wrap
            font.pixelSize: Theme.fontSizeExtraSmall
            color: Theme.primaryColor
            textFormat: Text.RichText;
            onLinkActivated: Qt.openUrlExternally(link)
            text: "Drag the corner points to crop the image before recognition. Moving: " + curPoint
        }

        Image {
            id: cropView
            anchors.top: info.bottom
            anchors.left: parent.left
            anchors.topMargin: Theme.paddingMedium * 2
            width: parent.width
            height: cropDialog.height - header.height - info.height - Theme.paddingMedium * 4
            fillMode: Image.PreserveAspectFit

            CornerPoint {

                id: topLeft
                objectName: "topLeft"
                visible: !loading
                x: (parent.width - parent.paintedWidth) / 2 - this.width / 2
                y: (parent.height - parent.paintedHeight) / 2 - this.height / 2

                onXChanged: {
                    zoom.x = cornerXRelativeToImg(x, topLeft);
                    addCorner(topLeft);
                    canvas.requestPaint();
                    curPoint = objectName
                }
                onYChanged: {
                    zoom.y = cornerYRelativeToImg(y, topLeft);
                    addCorner(topLeft);
                    canvas.requestPaint();
                    curPoint = objectName
                }

            }

            CornerPoint {
                id: topRight
                objectName: "topRight"
                visible: !loading
                x: (parent.width - parent.paintedWidth) / 2 + parent.paintedWidth - this.width / 2
                y: (parent.height - parent.paintedHeight) / 2 - this.height / 2

                onXChanged: {
                    zoom.x = cornerXRelativeToImg(x, topLeft);
                    addCorner(topRight);
                    canvas.requestPaint();
                    curPoint = objectName
                }
                onYChanged: {
                    zoom.y = cornerYRelativeToImg(y, topLeft);
                    addCorner(topRight);
                    canvas.requestPaint();
                    curPoint = objectName
                }

            }

            CornerPoint {
                id: bottomLeft
                objectName: "bottomLeft"
                visible: !loading
                x: (parent.width - parent.paintedWidth) / 2 - this.width / 2
                y: (parent.height - parent.paintedHeight) / 2 + parent.paintedHeight - this.height / 2

                onXChanged: {
                    zoom.x = cornerXRelativeToImg(x, topLeft);
                    addCorner(bottomLeft);
                    canvas.requestPaint();
                    curPoint = objectName
                }
                onYChanged: {
                    zoom.y = cornerYRelativeToImg(y, topLeft);
                    addCorner(bottomLeft);
                    canvas.requestPaint();
                    curPoint = objectName
                }

            }

            CornerPoint {
                id: bottomRight
                objectName: "bottomRight"
                visible: !loading
                x: (parent.width - parent.paintedWidth) / 2 + parent.paintedWidth - this.width / 2
                y: (parent.height - parent.paintedHeight) / 2 + parent.paintedHeight - this.height / 2

                onXChanged: {
                    zoom.x = cornerXRelativeToImg(x, topLeft);
                    addCorner(bottomRight);
                    canvas.requestPaint();
                    curPoint = objectName
                }
                onYChanged: {
                    zoom.y = cornerYRelativeToImg(y, topLeft);
                    addCorner(bottomRight);
                    canvas.requestPaint();
                    curPoint = objectName
                }

            }

            Canvas {
                id: canvas
                anchors.fill: parent
                z: 10

                onPaint: {
                    var context = getContext("2d");

                    var offset = topLeft.width / 2;

                    context.reset()
                    context.beginPath();
                    context.lineWidth = 2;
                    context.moveTo(topLeft.x + offset, topLeft.y + offset);
                    context.strokeStyle = "#87CEFA"

                    context.lineTo(topRight.x + offset, topRight.y + offset);
                    context.lineTo(bottomRight.x + offset, bottomRight.y + offset);
                    context.lineTo(bottomLeft.x + offset, bottomLeft.y + offset);
                    context.lineTo(topLeft.x + offset, topLeft.y + offset);
                    context.closePath();
                    context.stroke();
                }
            }
        }
    }

    Connections {
        target: tesseractAPI

        onRotated: {
            busyind.running = false;
            forwardNavigation: true;
            loading = false;
            cropView.source = path;
        }
    }

    function cornerXRelativeToImg(x, corner) {
        var transferred = (x - (cropView.width - cropView.paintedWidth) / 2 + corner.width / 2) * -5 + zoomArea.width / 2;
        return transferred;
    }

    function cornerYRelativeToImg(y, corner) {
        return (y - (cropView.height - cropView.paintedHeight) / 2  + corner.height / 2) * -5 + zoomArea.height / 2;
    }

    function addCorner(corner) {
        var offsetx = corner.width / 2;
        var offsety = corner.height / 2;
        var xScale = cropView.sourceSize.width / cropView.paintedWidth;
        var yScale = cropView.sourceSize.height / cropView.paintedHeight;
        cropPoints[corner.objectName] = Qt.point(xScale * (corner.x - (cropView.width - cropView.paintedWidth) / 2 + offsetx),
                                                 yScale * (corner.y - (cropView.height - cropView.paintedHeight) / 2 + offsety));
    }
}
