import QtQuick 2.4

PageInfoForm {
    id: infoForm
    tClock.text : Qt.formatDateTime(new Date(), "hh:mm ddd d MMMM")

    exitButtonMouseArea.onClicked: Qt.quit()

    Timer {
        id: textTimer
        interval: 1000
        repeat: true
        running: true
        onTriggered:{
            tClock.text = Qt.formatDateTime(new Date(), "hh:mm ddd d MMMM")
        }
    }

    Connections {
        target: QmlBridge
        onPositionUpdate:
        {
            tSpeed.text = String(Math.round(speed)) + " km/h"
            tRoadName.text = roadName
        }
    }
}

