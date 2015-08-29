import QtQuick 2.0
import Sailfish.Silica 1.0
import harbour.textractor.settingsmanager 1.0

Dialog {

    id: languageDialog
    property bool firstuse: false;

    Component.onCompleted: {
        listView.model = tesseractAPI.settings.getLanguageList();
        listView.currentIndex = tesseractAPI.settings.getLangIndex();
        if(firstuse) {
            info.height = 100;
            listView.topMargin = Theme.paddingMedium * 4
        }
    }

    onAccepted: {
        tesseractAPI.settings.setLanguage(current);
    }

    DialogHeader {
       id: header
       acceptText: "Select"
       cancelText: "Cancel"
    }

    backNavigation: tesseractAPI.settings.getLanguage().length !== 0
    forwardNavigation: current.length !== 0

    onStatusChanged: {
        if(status === PageStatus.Active && selectCompleted) {
            selectCompleted = false;
            pageStack.push(Qt.resolvedUrl("DownloadPage.qml"), { language: lang });
        }
    }

    Column {

        id: infolabel
        width: parent.width
        anchors.top: header.bottom
        height: childrenRect.height

        Label {
            id: info
            anchors.left: parent.left
            anchors.leftMargin: Theme.paddingLarge
            anchors.right: parent.right
            anchors.rightMargin: Theme.paddingLarge
            height: 70
            wrapMode: Text.Wrap
            font.pixelSize: Theme.fontSizeSmall
            color: Theme.primaryColor
            text: {
                if(!firstuse) {
                    return "Tap language to download and install.";
                } else {
                    return "Looks like you are using Textractor for the first time. Please select and download language to get going."
                }
            }

            z: 20
        }

    }

    SilicaListView {

        id: listView
        anchors.top: infolabel.bottom
        anchors.topMargin: Theme.paddingMedium * 4
        height: parent.height - header.childrenRect.height - infolabel.height - Theme.paddingMedium * 4
        width: parent.width


        delegate: ListItem {

            id: delegateitem
            height: Theme.ItemSizeMedium
            width: parent.width
            highlighted: listView.currentIndex == index;

            IconButton {
                icon.source: "image://theme/icon-l-check"
                enabled: false;
                visible: tesseractAPI.settings.isLangDataAvailable(modelData);
            }

            IconButton {
                icon.source: "image://theme/icon-s-update"
                enabled: false;
                visible: !tesseractAPI.settings.isLangDataAvailable(modelData);
            }

            Label {
                id: label2
                anchors.fill: parent
                text: modelData
                anchors.leftMargin: Theme.paddingLarge * 4
                verticalAlignment: Text.AlignVCenter
                color: delegateitem.highlighted ? Theme.highlightColor : Theme.primaryColor
            }

            onClicked: {
                if(tesseractAPI.settings.isLangDataAvailable(modelData)) {
                    listView.currentIndex = index;
                    current = modelData;
                } else {
                    var dialog = pageStack.push(Qt.resolvedUrl("DownloadDialog.qml"), { language: modelData });
                    lang = dialog.language;
                    dialog.accepted.connect(function() {
                        current = modelData;
                        selectCompleted = true;
                    })
                }
            }
        }
        VerticalScrollDecorator { flickable: listView }

    }

    property string current;
    property bool selectCompleted: false;
    property string lang;

    Connections {
        target: tesseractAPI

        onLanguageReady: {
            listView.model = [];
            var langs = tesseractAPI.settings.getLanguageList();
            listView.model = langs;
            listView.currentIndex = langs.indexOf(current);
        }
    }
}
