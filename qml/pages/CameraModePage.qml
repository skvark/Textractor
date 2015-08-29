import QtQuick 2.0
import Sailfish.Silica 1.0

Dialog {

    id: page
    property int shutter: 0;
    property int iso: 0;

    property var shutterSpeeds: [-1, 1/4000, 1/2000, 1/1000, 1/500, 1/250, 1/125, 1/60, 1/30, 1/15, 1/8, 1/4, 1/2, 1];
    property var shutterSpeedsStr: ["Auto", "1/4000", "1/2000", "1/1000", "1/500", "1/250", "1/125", "1/60", "1/30", "1/15", "1/8", "1/4", "1/2", "1"];

    property var isoSpeeds: [-1,  100, 200, 400, 1600];
    property var isoSpeedsStr: ["Auto", "100", "200", "400", "1600"];


    SilicaFlickable {
       id: flickable
       anchors.fill: parent
       contentWidth: flickable.width

        Column {
            id: locations
            anchors {
               left: parent.left
               right: parent.right
            }

            DialogHeader {
               id: header
               acceptText: "Set"
            }

            ComboBox {
               id: combo
               label: "Shutter Speed"
               description: "Set the shutter speed."
               currentIndex: shutter
               width: parent.width

               menu: ContextMenu {
                    id: shuttercontent
                    Repeater {
                        model: shutterSpeedsStr
                        delegate: MenuItem {
                            text: model.modelData
                        }
                    }
                }

               onCurrentItemChanged: {
                   shutter = currentIndex;
               }
            }

            ComboBox {
               id: combo2
               label: "ISO"
               description: "Set the ISO value."
               currentIndex: iso
               width: parent.width

               menu: ContextMenu {
                    id: isocontent
                    Repeater {
                        model: isoSpeedsStr
                        delegate: MenuItem {
                            text: model.modelData
                        }
                    }
                }

               onCurrentItemChanged: {
                   iso = currentIndex;
               }
            }
        }
    }
}
