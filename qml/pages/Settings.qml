import QtQuick 2.0
import Sailfish.Silica 1.0
import harbour.textractor.settingsmanager 1.0

Page {

    id: settingsPage

    SilicaFlickable {
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

        }

        Column {
            id: headerContainer
            width: settingsPage.width

            PageHeader {
                title: qsTr("Settings")
            }
        }

        SectionHeader {
            id: generalsection
            text: qsTr("OCR Language")
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

        SectionHeader {
            id: advancedsection
            text: qsTr("Advanced Settings")
            anchors.top: lang.bottom
            height: 40;

            Label {
                id: label2
                font.pixelSize: 22
                anchors.right: advancedsection.right
                anchors.top: advancedsection.bottom
                textFormat: Text.RichText
                text: "Modifying these might yeild better results."
                color: Theme.secondaryColor
            }

        }
    }

}
