import QtQuick 2.0
import Sailfish.Silica 1.0

Page {

    id: page

    SilicaFlickable {

        id: info
        anchors.fill: parent
        contentHeight: headerContainer.height + generalsection.height + takingpics.height + section2.height + section2text.height + 50

        Column {
            id: headerContainer
            width: page.width
            PageHeader {
                title: qsTr("Usage Hints")
            }
        }

        SectionHeader {
            id: generalsection
            text: qsTr("Taking a Good Picture")
            height: 50;
            anchors.top: headerContainer.bottom
        }

        Label {
            id: takingpics
            width: parent.width
            wrapMode: Text.Wrap
            font.pixelSize: Theme.fontSizeSmall
            color: Theme.primaryColor
            anchors.top: generalsection.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: Theme.paddingLarge
            anchors.rightMargin: Theme.paddingLarge
            textFormat: Text.RichText;
            onLinkActivated: Qt.openUrlExternally(link)
            text: "To get the best results you should follow a couple of simple guidelines when taking pictures:" +
                  "<ul>" +
                  "<li>Check that the lighting conditions are good. There should be no visible shadows or reflections in the image.</li>" +
                  "<li>Check that the color of the background is light and there are no complex textures in it. The background can be also dark: just make sure the text is white or some other light color.</li>" +
                  "<ul>";
        }

        SectionHeader {
            id: section2
            text: qsTr("Why the processing is very slow and results are obscure?")
            wrapMode: Text.WordWrap
            anchors.top: takingpics.bottom
            anchors.topMargin: Theme.paddingLarge
            anchors.bottomMargin: Theme.paddingLarge
            height: 100;
        }

        Label {
            id: section2text
            width: parent.width
            wrapMode: Text.Wrap
            font.pixelSize: Theme.fontSizeSmall
            color: Theme.primaryColor
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: section2.bottom
            anchors.leftMargin: Theme.paddingLarge
            anchors.rightMargin: Theme.paddingLarge
            textFormat: Text.RichText;
            onLinkActivated: Qt.openUrlExternally(link)
            text: "Processing will be very slow and the results are obscure if the quality of the picture is bad. Some examples of bad quality pictures:" +
                  "<ul>" +
                  "<li>Underexposure or overexposure</li>" +
                  "<li>Distorted (i.e. text is not straight or it's distorted) or blurred (camera moved during the shot) image</li>" +
                  "<li>There's complex image or texture behind the actual text to be regocnized</li>" +
                  "<li>Hand or some other object casted a shadow to the picture</li>" +
                  "<li>There are reflections in the picture</li>" +
                  "<li>The picture is in wrong orientation (text should be from left to right in most cases)</li>" +
                  "<ul>";
        }

        VerticalScrollDecorator { flickable: info }
    }

}
