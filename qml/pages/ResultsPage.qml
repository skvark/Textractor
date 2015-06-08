import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: page
    property bool loading;
    backNavigation: !loading

    SilicaFlickable {
        id: textcontainer
        anchors.fill: parent
        contentHeight: if(textholder.height < page.height) {
                           return page.height;
                       } else {
                           textholder.height
                       }

        BusyIndicator {
            anchors.centerIn: parent
            anchors.verticalCenterOffset: -200
            size: BusyIndicatorSize.Large
            running: loading
        }

        ViewPlaceholder {
            id: pholder
            anchors.centerIn: parent
            enabled: loading
            text: qsTr("Please wait. Processing may take several seconds.")
        }

        ViewPlaceholder {
            id: statusholder
            anchors.verticalCenterOffset: 200
            anchors.centerIn: parent
            enabled: loading
            text: ""
        }

        ViewPlaceholder {
            id: statusholder2
            anchors.verticalCenterOffset: 280
            anchors.centerIn: parent
            enabled: loading
            text: ""
        }

        Button {
            text: "Cancel"
            onClicked: tesseractAPI.cancel();
            visible: loading
            anchors.bottom: parent.bottom;
            anchors.bottomMargin: 50;
            anchors.horizontalCenter: parent.horizontalCenter
        }

        PullDownMenu {
            MenuItem {
                text: qsTr("Copy Text to Clipboard");
                onClicked: {
                    Clipboard.text = area.text;
                }
                enabled: !loading
            }

            MenuItem {
                text: qsTr("Edit");
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("EditPage.qml"), { editText: area.text })
                }
                enabled: !loading
            }
        }

        Column {
            id: textholder

            PageHeader {
                title: qsTr("Extracted text")
            }

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: Theme.paddingLarge
            anchors.rightMargin: Theme.paddingLarge
            anchors.topMargin: Theme.paddingLarge
            height: childrenRect.height

            Text {
                id: area
                width: parent.width
                wrapMode: Text.Wrap
                anchors.topMargin: Theme.paddingLarge
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.primaryColor
                textFormat: Text.PlainText;
                onLinkActivated: Qt.openUrlExternally(link)
                text: ""
            }
        }
        VerticalScrollDecorator { flickable: info }
    }

    Connections {
        target: tesseractAPI
        onAnalyzed: {
            area.text = text;
            textholder.height = area.height + 50
            loading = false;
        }
        onStateChanged: {
            statusholder.text = state;
        }
        onPercentageChanged: {
            statusholder2.text = percentage.toString() + " %";
        }
    }
}





