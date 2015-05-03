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

    SilicaListView {

        id: listView
        anchors.top: parent.top
        anchors.topMargin: header.childrenRect.height
        height: parent.height - header.childrenRect.height
        width: parent.width
        delegate: ListItem {

            id: delegate
            height: Theme.ItemSizeMedium
            width: parent.width
            highlighted: listView.currentIndex == index;

            Label {
                id: label2
                anchors.fill: parent
                text: modelData
                anchors.leftMargin: Theme.paddingLarge
                verticalAlignment: Text.AlignVCenter
                color: delegate.highlighted ? Theme.highlightColor : Theme.primaryColor
            }

            onClicked: {
                listView.currentIndex = index;
                current = modelData;
            }

        }
        VerticalScrollDecorator { flickable: listView }
    }

    property string current;
}
