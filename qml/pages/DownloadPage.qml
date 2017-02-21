import QtQuick 2.0
import Sailfish.Silica 1.0

Page {

    id: page
    property string language;

    Component.onCompleted: {
        tesseractAPI.downloadLanguage(language);
    }

    Timer {
        id: timer
        interval: 100;
        running: false;
        repeat: false;
        onTriggered: pageStack.pop();
    }

    backNavigation: false;

    BusyIndicator {
        id: busyind
        anchors.centerIn: page
        size: BusyIndicatorSize.Large
        running: false;
    }

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

    }

    Connections {
        target: tesseractAPI

        onLanguageReady: {
            busyind.running = false;
            page.backNavigation = true;
            tesseractAPI.settings.setLanguage(language);
            timer.start();
        }

        onProgressStatus: {
            var percentage = Math.round((downloaded / total) * 100);
            bar.value = percentage;
        }
    }
}
