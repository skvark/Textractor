import QtQuick 2.0
import Sailfish.Silica 1.0
import harbour.textractor.settingsmanager 1.0

Dialog {

    id: pageDialog
    property bool loading: true;
    property string currentStatus: "";
    property var selectedItems: [];
    property bool allSelected: false;

    DialogHeader {
       id: header
       acceptText: "Analyze"
       cancelText: "Cancel"
    }

    canAccept: false
    backNavigation: !loading

    Column {

        id: infolabel
        width: pageDialog.width
        anchors.top: header.bottom
        height: childrenRect.height

        Label {
            id: info
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: Theme.paddingLarge
            anchors.rightMargin: Theme.paddingLarge
            width: parent.width
            height: 60
            wrapMode: Text.Wrap
            font.pixelSize: Theme.fontSizeSmall
            color: Theme.primaryColor
            text: "Select the pages from which you want to extract text."
            z: 20
        }
    }

    SilicaListView {

        id: listView
        anchors.top: infolabel.bottom
        anchors.topMargin: Theme.paddingMedium * 2
        height: parent.height - header.childrenRect.height - infolabel.height - Theme.paddingMedium * 2
        width: parent.width
        clip: true

        BusyIndicator {
            id: busyind
            anchors.centerIn: parent
            size: BusyIndicatorSize.Large
            running: loading
        }

        ViewPlaceholder {
            id: statusholder
            anchors.verticalCenterOffset: 100
            anchors.centerIn: parent
            enabled: loading
            text: "Preparing PDF pages for preview...\n\r"
        }

        delegate: ListItem {

            id: delegateitem
            width: parent.width
            height: img.height + Theme.paddingLarge
            contentHeight: childrenRect.height
            anchors.topMargin: Theme.paddingLarge
            down: selectedItems.indexOf(index) !== -1

            Image {
                id: img
                source: "image://thumbnails/" + modelData
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                cache: false
            }

            Rectangle {
                anchors.fill: img
                color: Theme.rgba(Theme.highlightBackgroundColor, 0.3)
                visible: delegateitem.highlighted
            }

            onClicked: {
                if(!down) {
                    down = true;
                    selectedItems.push(index);
                } else {
                    selectedItems.splice(selectedItems.indexOf(index), 1);
                    down = false;
                }
                if(selectedItems.length > 0) {
                    pageDialog.canAccept = true;
                } else {
                    pageDialog.canAccept = false;
                }
            }
        }
        VerticalScrollDecorator { flickable: listView }

    }

    Connections {
        target: tesseractAPI

        onThumbnailsReady: {
            listView.model = ids;
            loading = false;
        }

        onProgressChanged: {
            statusholder.text = "Preparing PDF pages for preview...\n\r" + pstatus
        }
    }
}
