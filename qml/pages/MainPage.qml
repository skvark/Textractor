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
    }
}
