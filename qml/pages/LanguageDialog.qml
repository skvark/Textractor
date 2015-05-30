import QtQuick 2.0
import Sailfish.Silica 1.0
import harbour.textractor.settingsmanager 1.0

Dialog {

    id: languageDialog
    backNavigation: tesseractAPI.settings.getLanguage().length !== 0

    Component.onCompleted: {
        listView.model = tesseractAPI.settings.getLanguageList();
        listView.currentIndex = tesseractAPI.settings.getLangIndex();
    }

    onAccepted: {
        tesseractAPI.settings.setLanguage(current);
    }

    DialogHeader {
       id: header
       acceptText: "Select"
       cancelText: "Cancel"
    }

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
            anchors.left: parent.left
            anchors.leftMargin: Theme.paddingLarge
            width: parent.width
            height: 70
            wrapMode: Text.Wrap
            font.pixelSize: Theme.fontSizeSmall
            color: Theme.primaryColor
            text: "Tap language to download and install."
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
                lastIndex = index;
                if(tesseractAPI.settings.isLangDataAvailable(modelData)) {
                    listView.currentIndex = index;
                    current = modelData;
                } else {
                    var dialog = pageStack.push(Qt.resolvedUrl("DownloadDialog.qml"), { language: modelData });
                    lang = dialog.language;
                    dialog.accepted.connect(function() {
                        listView.currentIndex = lastIndex;
                        current = modelData;
                        selectCompleted = true;
                    })
                }
            }
        }
        VerticalScrollDecorator { flickable: listView }

    }

    property string current;
    property int lastIndex;
    property bool selectCompleted: false;
    property string lang;

    Connections {
        target: tesseractAPI

        onLanguageReady: {
            listView.model = [];
            listView.model = tesseractAPI.settings.getLanguageList();
            listView.currentIndex = lastIndex;
        }
    }
}
