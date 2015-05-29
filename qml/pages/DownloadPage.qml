import QtQuick 2.0
import Sailfish.Silica 1.0

Page {

    id: mainPage
    property string language;

    Component.onCompleted: {
        tesseractAPI.downloadLanguage(language);
    }

    backNavigation: false;

    SilicaFlickable {
        id: flickable
        anchors.fill: parent

        Column {
            id: headerContainer
            width: parent.width

            PageHeader {
                title: qsTr("Downloading language")
            }
        }

        ProgressBar {
            id: bar
            anchors.top: headerContainer.bottom;
            anchors.topMargin: 50;
            width: parent.width
            anchors.leftMargin: Theme.paddingMedium;
            anchors.rightMargin: Theme.paddingMedium;
            minimumValue: 0
            maximumValue: 100
            value: 0
            valueText: value + "%"
            label: "Downloading " + language + " ..."
        }

        BusyIndicator {
            id: busyind
            anchors.centerIn: parent
            size: BusyIndicatorSize.Large
            running: false;
        }

    }

    Connections {
        target: tesseractAPI

        onLanguageReady: {
            busyind.running = false;
            backNavigation: true;
            tesseractAPI.settings.setLanguage(language);
            pageStack.pop();
        }

        onLanguageExtracting: {
            busyind.running = true;
            bar.label = "Installing " + language + " ...";
        }

        onProgressStatus: {
            var percentage = Math.round((downloaded / total) * 100);
            bar.value = percentage;
        }
    }
}
