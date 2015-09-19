import QtQuick 2.0
import Sailfish.Silica 1.0

CoverBackground {

    Label {
        id: label
        text: "Textractor"
        width: parent.width
        anchors.top: parent.top
        anchors.leftMargin: Theme.paddingSmall
        anchors.rightMargin: Theme.paddingSmall
        anchors.topMargin: Theme.paddingLarge
        horizontalAlignment: Text.AlignHCenter
    }

    Label {
        id: label2
        text: ""
        anchors.top: label.bottom
        width: parent.width
        anchors.leftMargin: Theme.paddingSmall
        anchors.rightMargin: Theme.paddingSmall
        anchors.topMargin: Theme.paddingLarge
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.Wrap
    }

    Label {
        id: label3
        anchors.top: label2.bottom
        width: parent.width
        anchors.leftMargin: Theme.paddingSmall
        anchors.rightMargin: Theme.paddingSmall
        anchors.topMargin: Theme.paddingLarge
        anchors.horizontalCenter: parent.horizontalCenter
        text: ""
        wrapMode: Text.Wrap
        font.pixelSize: Theme.fontSizeExtraLarge
        horizontalAlignment: Text.AlignHCenter
    }

    Connections {
        target: tesseractAPI

        onAnalyzed: {
            label.text = "Textractor"
            label2.text = "Idle"
            label3.text = ""
        }

        onStateChanged: {
            label2.text = state;
        }

        onPercentageChanged: {
            label3.text = percentage.toString() + " %";
        }
    }
}


