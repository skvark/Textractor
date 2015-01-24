import QtQuick 2.0
import Sailfish.Silica 1.0


Page {
    id: page
    property string editText;

    Component.onCompleted: {
        area.text = editText;
    }

    SilicaFlickable {

        anchors.fill: parent

        PullDownMenu {
            MenuItem {
                text: qsTr("Copy Text to Clipboard");
                onClicked: {
                    Clipboard.text = area.text;
                }
            }
        }

        Column {

            PageHeader {
                title: qsTr("Edit text")
            }

            id: column
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: Theme.paddingLarge
            anchors.rightMargin: Theme.paddingLarge
            anchors.topMargin: Theme.paddingLarge

            TextArea {
                id: area
                width: parent.width
                height: 450
                wrapMode: Text.Wrap
                anchors.topMargin: Theme.paddingLarge
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.primaryColor
                text: editText
            }
        }
    }
}
