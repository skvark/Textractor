import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: page

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height

        Column {
            id: column
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: Theme.paddingLarge
            anchors.rightMargin: Theme.paddingLarge
            anchors.topMargin: Theme.paddingLarge * 2
            height: childrenRect.height

            Label {
                width: parent.width
                wrapMode: Text.Wrap
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.primaryColor
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                textFormat: Text.RichText;
                onLinkActivated: Qt.openUrlExternally(link)
                text: "<h2>Textractor</h2>v"+APP_VERSION+"<br /><br />" +

                      "<style> .legend { font-size: 22px;  } </style>" +
                      "<style>a:link { color: " + Theme.highlightColor + "; }</style>" +

                      "<span class=\"legend\">Created by</span><br />Olli-Pekka Heinisuo<br /><br />" +
                      "<span class=\"legend\">Icon and cover image by</span><br />Janne Peltonen<br /><br />" +

                      "<font style=\"font-size: 25px;\">Textractor is an OCR (optical character recognition) application.<br /><br />" +
                      "Textractor uses <a href='https://code.google.com/p/tesseract-ocr/'>Tesseract OCR</a> engine to perform actual OCR and " +
                      "<a href='http://www.leptonica.com/'>Leptonica</a> image processing library for general image manipulation.</font><br /><br />" +

                      "<span class=\"legend\">Tesseract OCR version</span><br />" + tesseractAPI.tesseractVersion() + "<br />" +

                      "<span class=\"legend\">Leptonica version</span><br />" + tesseractAPI.leptonicaVersion() + "<br /><br />" +

                      "<font style=\"font-size: 25px;\">This software is released under MIT license.<br />" +
                      "You can get the code and contribute at:</font>\n" +
                      "<br />" +
                      "<a href='http://github.com/skvark/Textractor'>GitHub \\ Textractor</a>";
            }
        }
    }
}
