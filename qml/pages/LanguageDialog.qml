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

    SilicaListView {

        id: listView
        anchors.top: parent.top
        anchors.topMargin: header.height
        height: parent.height - header.childrenRect.height
        width: parent.width

        delegate: ListItem {

            id: delegate
            height: Theme.ItemSizeMedium
            width: parent.width
            highlighted: listView.currentIndex == index;

            IconButton {
                icon.source: "image://theme/icon-header-accept"
                enabled: false;
                visible: tesseractAPI.settings.isLangDataAvailable(modelData);
            }

            Label {
                id: label2
                anchors.fill: parent
                text: modelData
                anchors.leftMargin: Theme.paddingLarge + Theme.paddingLarge + Theme.paddingLarge
                verticalAlignment: Text.AlignVCenter
                color: delegate.highlighted ? Theme.highlightColor : Theme.primaryColor
            }

            onClicked: {
                if(tesseractAPI.settings.isLangDataAvailable(modelData)) {
                    listView.currentIndex = index;
                    current = modelData;
                } else {
                    var dialog = pageStack.push(Qt.resolvedUrl("DownloadDialog.qml"), { language: modelData });
                    lang = dialog.language;
                    dialog.accepted.connect(function() {
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
            listView.model = tesseractAPI.settings.getLanguageList();
            listView.currentIndex = tesseractAPI.settings.getLangIndex();
        }
    }
}
