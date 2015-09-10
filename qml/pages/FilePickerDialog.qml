import QtQuick 2.0
import Sailfish.Silica 1.0
import harbour.textractor.folderlistmodel 1.0

Dialog {

    id: filePicker
    property string currentFolder: "/home/nemo/";
    property url selectedFile: "";

    SilicaFlickable {

        id: flickable
        anchors.fill: parent
        contentHeight: childrenRect.height

        PullDownMenu {
            id: menu

            MenuItem {
                text: qsTr("Sort by Name");
                onClicked: {
                    folderModel.sortField = FolderListModel.Name
                }
            }

            MenuItem {
                text: qsTr("Sort by Type");
                onClicked: {
                    folderModel.sortField = FolderListModel.Type
                }
            }

            MenuItem {
                text: qsTr("Sort by Last Modified");
                onClicked: {
                    folderModel.sortField = FolderListModel.Time
                }
            }
        }

        PageHeader {
            id: headertext
            title: "Pick a File"
        }

        BackgroundItem {

            id: parentFolder
            width: parent.width
            height: Theme.itemSizeSmall
            anchors.top: headertext.bottom
            anchors.left: parent.left
            anchors.right: parent.right

            Image {
                fillMode: Image.Pad
                horizontalAlignment: Image.AlignHCenter
                verticalAlignment: Image.AlignVCenter
                id: parentBall1
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                source: "image://theme/graphic-toggle-on"
            }

            Image {
                fillMode: Image.Pad
                horizontalAlignment: Image.AlignHCenter
                verticalAlignment: Image.AlignVCenter
                id: parentBall2
                anchors.left: parentBall1.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.leftMargin: Theme.paddingSmall * 5
                source: "image://theme/graphic-toggle-on"
            }

            Text {
                width: parent.width - parentBall1.width - parentBall2.width - Theme.paddingLarge * 2
                anchors.top: parent.top
                anchors.left: parentBall2.right
                anchors.right: parent.right
                height: parent.height
                wrapMode: Text.Wrap
                font.pixelSize: 25
                color: Theme.primaryColor
                verticalAlignment: Text.AlignVCenter
                anchors.leftMargin: Theme.paddingSmall
                anchors.rightMargin: Theme.paddingSmall
                text: currentFolder
            }

            onClicked: {
                currentFolder = String(folderModel.parentFolder).replace("file://", "");
                if(currentFolder !== "") {
                    folderModel.folder = folderModel.parentFolder;
                }
            }
        }

        SilicaListView {

            id: fileList
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parentFolder.bottom
            anchors.topMargin: Theme.paddingLarge
            model: folderModel
            height: filePicker.height - headertext.height - parentFolder.height - Theme.paddingLarge
            clip: true

            FolderListModel {
                id: folderModel
                // afaik there's no way to get standard paths via qml...
                folder: currentFolder
                showOnlyReadable: true
            }

            delegate: BackgroundItem {

                id: fileDelegate
                width: parent.width
                height: Theme.itemSizeSmall
                anchors.left: parent.left
                anchors.right: parent.right

                Image {
                    fillMode: Image.Pad
                    horizontalAlignment: Image.AlignHCenter
                    verticalAlignment: Image.AlignVCenter
                    id: foldericon
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.leftMargin: Theme.paddingLarge
                    source: "image://theme/icon-m-folder"
                    visible: fileIsDir

                }

                Label {
                    id: namelabel
                    anchors {
                        left: if(fileIsDir) {
                                  foldericon.right
                              } else {
                                  parent.left
                              }
                        right: parent.right
                        leftMargin: Theme.paddingLarge
                        rightMargin: Theme.paddingLarge
                        topMargin: 15
                    }
                    textFormat: Text.RichText
                    text: fileName
                }

                Label {
                    id: sizelabel
                    anchors {
                        left: if(fileIsDir) {
                                  foldericon.right
                              } else {
                                  parent.left
                              }
                        right: parent.right
                        top: namelabel.bottom
                        leftMargin: Theme.paddingLarge
                        rightMargin: Theme.paddingLarge
                    }

                    font.pixelSize: 20
                    textFormat: Text.RichText
                    text: parseInt(fileSize) / 1000 + " kB, " + fileModified
                    color: Theme.rgba(Theme.secondaryColor, 0.5)
                }

                onClicked: {
                    if(folderModel.isFolder(index)) {
                        folderModel.folder = fileURL;
                        currentFolder = String(fileURL).replace("file://", "");
                    } else {
                        selectedFile = fileURL;
                        filePicker.accept();
                    }
                }
            }

            VerticalScrollDecorator {
                flickable: fileList

            }
        }
    }
}
