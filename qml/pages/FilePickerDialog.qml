import QtQuick 2.0
import Sailfish.Silica 1.0
import harbour.textractor.folderlistmodel 1.0

Dialog {

    id: filePicker
    property url selectedFile: "";
    property string currentFolder: "";
    property int lastSelected: -1;
    canAccept: false

    Component.onCompleted: {
        folderModel.folder = tesseractAPI.homePath();
        currentFolder = tesseractAPI.homePath();
    }

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
                anchors.leftMargin: Theme.paddingLarge
                id: folderup
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                rotation: -90
                source: "image://theme/icon-m-page-up"
                visible: currentFolder != "/"
            }

            Text {
                width: parent.width - folderup.width - Theme.paddingLarge * 3
                anchors.top: parent.top
                anchors.left: folderup.right
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
                var folder = String(folderModel.parentFolder).replace("file://", "");
                if(folder !== "") {
                    currentFolder = folder;
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
                showOnlyReadable: true
                nameFilters: ["*.pdf"]
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
                        lastSelected = -1;
                        folderModel.folder = fileURL;
                        currentFolder = String(fileURL).replace("file://", "");
                    } else {
                        canAccept = true;
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
