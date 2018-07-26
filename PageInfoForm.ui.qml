import QtQuick 2.4

Item {
    id: item2
    width: 1024
    height: 600
    property alias tSpeed: tSpeed
    property alias tClock: tClock
    property alias exitButtonMouseArea: exitButtonMouseArea

    Rectangle {
        id: rectangle
        color: "#000000"
        anchors.fill: parent

        Text {
            id: tClock
            color: "#ffffff"
            text: ""
            anchors.left: parent.left
            anchors.leftMargin: 20
            anchors.topMargin: 20
            anchors.top: parent.top
            verticalAlignment: Text.AlignTop
            horizontalAlignment: Text.AlignLeft
            font.pointSize: 30
            font.family: robotoLight.name
            font.weight: Font.Light // this is necessary or else it'll look like Roboto-Bold
        }

        TextInput {
            x: 866
            text: "Test Input"
            anchors.top: parent.top
            anchors.topMargin: 20
            anchors.right: parent.right
            anchors.rightMargin: 20
            font.pointSize: 30
            font.family: robotoLight.name
            font.weight: Font.Light // this is necessary or else it'll look like Roboto-Bold
            cursorVisible: false
            color: "#ffffff"
            width: 150
            height: 30
        }

        Item {
            id: exitItem
            x: 796
            y: 359
            width: 150
            height: 150
            anchors.right: parent.right
            anchors.rightMargin: 20
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 20

            Text {
                id: exitText
                color: "#ffffff"
                text: qsTr("Quit")
                font.family: robotoLight.name
                font.weight: Font.Light
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                anchors.fill: parent
                font.pointSize: 20

                MouseArea {
                    id: exitButtonMouseArea
                    anchors.fill: parent
                }
            }
        }

        Text {
            id: tSpeed
            width: 36
            height: 33
            color: "#ffffff"
            text: qsTr("0")
            font.family: robotoLight.name
            font.weight: Font.Light
            anchors.top: tClock.bottom
            anchors.topMargin: 40
            anchors.left: parent.left
            anchors.leftMargin: 20
            font.pointSize: 30
        }
    }
}

/*##^## Designer {
    D{i:3;anchors_y:118}
}
 ##^##*/
