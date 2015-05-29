import QtQuick 2.0
import Sailfish.Silica 1.0
import harbour.textractor.settingsmanager 1.0

Dialog {

    id: downloadDialog
    property string language;

    DialogHeader {
       id: header
       acceptText: "Download"
       cancelText: "Cancel"
    }

    Column {
        id: column
        anchors.top: header.bottom;
        anchors.topMargin: 50;
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: Theme.paddingLarge
        anchors.rightMargin: Theme.paddingLarge

        Label {
            width: parent.width
            height: 800
            wrapMode: Text.Wrap
            font.pixelSize: Theme.fontSizeLarge
            color: Theme.primaryColor
            textFormat: Text.RichText;
            onLinkActivated: Qt.openUrlExternally(link)
            text: "Language data for " + language + " hasn't been yet downloaded.<br /><br />" +
                  "Do you want to download the language data?"

        }
    }
}
