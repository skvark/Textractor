import QtQuick 2.0
import Sailfish.Silica 1.0
import harbour.textractor.settingsmanager 1.0

Page {

    id: settingsPage

    SilicaFlickable {
        id: settingsflickable
        anchors.fill: parent
        contentHeight: 400 + advanced.height

        PullDownMenu {
            id: menu

            MenuItem {
                text: "About"
                onClicked: {
                    pageStack.push("About.qml");
                }
            }

            MenuItem {
                text: "Reset to Defaults"
                onClicked: {
                    tesseractAPI.resetSettings();
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
            id: advancedsection
            text: qsTr("Advanced Settings")
            font.pixelSize: Theme.fontSizeMedium
            anchors.top: headerContainer.bottom
            anchors.topMargin: 10
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

        Column {

            id: advanced
            anchors.top: advancedsection.bottom
            width: settingsPage.width
            anchors.topMargin: 30
            height: childrenRect.height

            Slider {
                id: tilesize
                label: "Tile size in pixels."
                width: parent.width
                anchors.topMargin: 20
                stepSize: 1
                minimumValue: 20
                maximumValue: 2000
                value: tesseractAPI.settings.getTileSize();
                valueText: value + " x " + value + " px"
                onValueChanged: tesseractAPI.settings.setTileSize(value);
            }

            Slider {
                id: threshold
                label: "Threshold for determining foreground."
                width: parent.width
                anchors.topMargin: 20
                stepSize: 1
                minimumValue: 0
                maximumValue: 255
                value: tesseractAPI.settings.getThreshold();
                valueText: value
                onValueChanged: tesseractAPI.settings.setThreshold(value);
            }

            Slider {
                id: mincount
                label: "Min threshold on counts in a tile."
                width: parent.width
                anchors.topMargin: 20
                stepSize: 1
                minimumValue: 0
                maximumValue: 255
                value: tesseractAPI.settings.getMinCount();
                valueText: value
                onValueChanged: tesseractAPI.settings.setMinCount(value);
            }


            Slider {
                id: bgval
                label: "Target bg value for the normalized image."
                width: parent.width
                anchors.topMargin: 20
                stepSize: 1
                minimumValue: 0
                maximumValue: 255
                value: tesseractAPI.settings.getBgVal();
                valueText: value
                onValueChanged: tesseractAPI.settings.setBgVal(value);
            }


            Slider {
                id: smoothing
                label: "Smoothing factor."
                width: parent.width
                anchors.topMargin: 20
                stepSize: 1
                minimumValue: 0
                maximumValue: 10
                value: tesseractAPI.settings.getSmoothingFactor();
                valueText: value
                onValueChanged: tesseractAPI.settings.setSmoothingFactor(value);
            }


            Slider {
                id: scorefract
                label: "Otsu score fraction."
                width: parent.width
                anchors.topMargin: 20
                stepSize: 0.01
                minimumValue: 0
                maximumValue: 0.15
                value: tesseractAPI.settings.getScoreFract();
                valueText: value.toFixed(2);
                onValueChanged: tesseractAPI.settings.setScoreFract(value);
            }

        }
        VerticalScrollDecorator { flickable: settingsflickable }
    }

    Connections {
        target: tesseractAPI
        onReset: {
            scorefract.value = tesseractAPI.settings.getScoreFract();
            smoothing.value = tesseractAPI.settings.getSmoothingFactor();
            bgval.value = tesseractAPI.settings.getBgVal();
            mincount.value = tesseractAPI.settings.getMinCount();
            threshold.value = tesseractAPI.settings.getThreshold();
            tilesize.value = tesseractAPI.settings.getTileSize();
        }
    }

}
