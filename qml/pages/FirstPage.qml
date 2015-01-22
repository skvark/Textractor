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
import QtMultimedia 5.0


Page {
    id: page

    // To enable PullDownMenu, place our content in a SilicaFlickable
    SilicaFlickable {
        anchors.fill: parent

        // PullDownMenu and PushUpMenu must be declared in SilicaFlickable, SilicaListView or SilicaGridView
        PullDownMenu {
            MenuItem {
                text: qsTr("Show Page 2")
                onClicked: pageStack.push(Qt.resolvedUrl("SecondPage.qml"))
            }
        }

        Item {
           id: cameraOutput
           x: 0
           y: 0
           anchors.fill: parent
           width: 540
           height: 960

            Camera {

                id: camera

                focus {
                    focusMode: Camera.FocusContinuous
                    focusPointMode: Camera.FocusPointCenter
                }

                flash.mode: Camera.FlashOff

                imageProcessing {
                    sharpeningLevel: 1

                }

                exposure {
                    exposureCompensation: 1.0
                    exposureMode: Camera.ExposurePortrait
                }

            }

            VideoOutput {
               id: videoPreview
               source: camera
               width: 480
               anchors.centerIn: parent
           }
        }

        Row {

            anchors {
                bottom: parent.bottom
                bottomMargin: Theme.paddingMedium
                horizontalCenter: parent.horizontalCenter
            }

            IconButton {

                id: cameraButton
                width: page.width / 3
                icon.source: "image://theme/icon-camera-shutter-release"
                scale: 1.5
                onClicked: {
                    camera.imageCapture.capture();
                }
            }
            z: 30
        }

    }

    Connections {
        target: camera.imageCapture
        onImageSaved: {
            camera.cameraState = Camera.UnloadedState
            tesseractAPI.analyze(path);
            pageStack.push(Qt.resolvedUrl("SecondPage.qml"), { loading: true })
        }
    }

    Connections {
        target: tesseractAPI
        onAnalyzed: {
            camera.cameraState = Camera.LoadedState
        }
    }

}


