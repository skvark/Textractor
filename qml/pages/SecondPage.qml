/*
  Copyright (C) 2013 Jolla Ltd.
  Contact: Thomas Perl <thomas.perl@jollamobile.com>
  All rights reserved.

  You may use this file under the terms of BSD license as follows:

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the Jolla Ltd nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR
  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

import QtQuick 2.0
import Sailfish.Silica 1.0


Page {
    id: page
    property bool loading;

    SilicaFlickable {

        anchors.fill: parent

        BusyIndicator {
            anchors.centerIn: parent
            anchors.verticalCenterOffset: -200
            size: BusyIndicatorSize.Large
            running: loading
        }

        ViewPlaceholder {
            id: pholder
            anchors.centerIn: parent
            enabled: loading
            text: qsTr("Please wait. Processing may take several seconds.")
        }

        ViewPlaceholder {
            id: statusholder
            anchors.verticalCenterOffset: 200
            anchors.centerIn: parent
            enabled: loading
            text: ""
        }

        PullDownMenu {
            MenuItem {
                text: qsTr("Copy text to clipboard");
                onClicked: {
                    Clipboard.text = area.text;
                }
            }
        }

        Column {
            id: column
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: Theme.paddingLarge
            anchors.rightMargin: Theme.paddingLarge
            anchors.topMargin: Theme.paddingLarge

            Label {
                id: area
                width: parent.width
                wrapMode: Text.Wrap
                anchors.topMargin: Theme.paddingLarge
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.primaryColor
                textFormat: Text.RichText;
                onLinkActivated: Qt.openUrlExternally(link)
                text: ""
            }
        }
    }

    Connections {
        target: tesseractAPI
        onAnalyzed: {
            area.text = text;
            loading = false;
        }
        onStateChanged: {
            statusholder.text = state;
        }
    }
}





