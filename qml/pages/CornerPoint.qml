import QtQuick 2.0
import Sailfish.Silica 1.0

Rectangle {

    id: corner
    width: 40;
    height: 40;
    Drag.active: area.drag.active
    radius: width / 2
    border.width: 3
    border.color: "blue"
    color: "transparent"

    MouseArea {

        id: area
        x: -50
        y: -50
        width: parent.width * 4
        height: parent.height * 4
        drag.axis: Drag.XandYAxis
        drag.target: parent
        drag.minimumX: (parent.parent.width - parent.parent.paintedWidth - parent.width) / 2
        drag.maximumX: (parent.parent.width + parent.parent.paintedWidth - parent.width) / 2
        drag.minimumY: (parent.parent.height - parent.parent.paintedHeight - parent.height) / 2
        drag.maximumY: (parent.parent.height + parent.parent.paintedHeight - parent.height) / 2

    }

}
