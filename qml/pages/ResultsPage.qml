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

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: Theme.paddingSmall
        anchors.rightMargin: Theme.paddingSmall

        Image {
            id: preprocessedim
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.topMargin: Theme.paddingLarge
            width: parent.width
            height: page.height / 4 * 2.7
            fillMode: Image.PreserveAspectFit
            cache: false
            visible: loading
        }

        BusyIndicator {
            id: busyind
            anchors.centerIn: parent
            size: BusyIndicatorSize.Large
            anchors.verticalCenterOffset: -160
            running: !preprocessed;
        }

        ViewPlaceholder {
            id: statusholder
            anchors.verticalCenterOffset: 250
            anchors.centerIn: parent
            enabled: loading
            text: ""
        }

        ViewPlaceholder {
            id: statusholder2
            anchors.verticalCenterOffset: 330
            anchors.centerIn: parent
            enabled: loading
            text: ""
        }

        Button {
            text: "Cancel"
            onClicked: tesseractAPI.cancel();
            visible: loading
            anchors.bottom: parent.bottom;
            anchors.bottomMargin: 30;
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
                visible: !loading
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

    property bool preprocessed: false;

    Connections {
        target: tesseractAPI
        onAnalyzed: {
            area.text = text;
            textholder.height = area.height + 50
            loading = false;
        }
        onStateChanged: {
            statusholder.text = state;
            if(state === "Running OCR..." && preprocessed === false) {
                preprocessedim.source = tesseractAPI.getPrepdPath();
                preprocessed = true;
            }
        }
        onPercentageChanged: {
            statusholder2.text = percentage.toString() + " %";
        }
    }
}





