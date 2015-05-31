import QtQuick 2.0
import Sailfish.Silica 1.0
import harbour.textractor.settingsmanager 1.0

Page {

    id: mainPage

    SilicaFlickable {
        id: flickable
        anchors.fill: parent
        contentHeight: childrenRect.height

        PullDownMenu {
            id: menu

            MenuItem {
                text: "About"
                onClicked: {
                    pageStack.push("About.qml");
                }
            }

            MenuItem {
                text: qsTr("Usage Hints");
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("HintsPage.qml"))
                }
            }

            MenuItem {
                text: "Settings"
                onClicked: {
                    pageStack.push("Settings.qml");
                }
            }

        }

        Column {
            id: headerContainer
            width: parent.width

            PageHeader {
                title: qsTr("Textractor")
            }
        }

        SectionHeader {
            id: generalsection
            text: qsTr("OCR Language")
            font.pixelSize: Theme.fontSizeMedium
            anchors.top: headerContainer.bottom
            height: 50;
        }

        ValueButton {
            id: lang
            label: "Language"
            anchors.top: generalsection.bottom
            value: tesseractAPI.settings.getLanguage();

            onClicked: {
                var dialog = pageStack.push("LanguageDialog.qml")

                dialog.accepted.connect(function() {
                    value = tesseractAPI.settings.getLanguage();
                })
            }
        }


        BackgroundItem {
            id: button1
            anchors.top: lang.bottom
            anchors.topMargin: 25;
            anchors.left: parent.left
            width: parent.width - 4 * Theme.paddingMedium
            anchors.leftMargin: 2 * Theme.paddingMedium
            height: 300
            z: -1

            Image {
                anchors.fill: parent
                fillMode: Image.Pad
                horizontalAlignment: Image.AlignHCenter
                verticalAlignment: Image.AlignVCenter
                source: "image://theme/graphics-cover-camera"
                z: 30
            }

            Label {
                anchors.topMargin: 20;
                anchors.top: parent.top
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                text: "Take a picture"
            }

            onClicked: {
                pageStack.push("CameraPage.qml")
            }
        }

        BackgroundItem {
            id: button2
            anchors.top: button1.bottom
            anchors.left: parent.left
            anchors.topMargin: 25;
            width: parent.width - 4 * Theme.paddingMedium
            anchors.leftMargin: 2 * Theme.paddingMedium
            height: 300
            z: -1

            Image {
                anchors.fill: parent
                fillMode: Image.Pad
                horizontalAlignment: Image.AlignHCenter
                verticalAlignment: Image.AlignVCenter
                source: "image://theme/icon-l-image"
                z: 30
            }

            Label {
                anchors.topMargin: 20;
                anchors.top: parent.top
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                text: "Select an image from the gallery"
            }

            onClicked: {

            }
        }

        Rectangle {
            anchors.fill: button1
            radius: 10;
            color: Theme.rgba(Theme.highlightBackgroundColor, 0.3)
        }

        Rectangle {
            anchors.fill: button2
            radius: 10;
            color: Theme.rgba(Theme.highlightBackgroundColor, 0.3)
        }
    }
}
