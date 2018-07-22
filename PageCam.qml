import QtQuick 2.0
import QtQuick.Controls 2.3
import QtMultimedia 5.4

Item {
    width: 1024
    height: 600

    Rectangle {
        id: camRect
        color: "#000054"
        width: 720
        height: 576
        anchors.left: parent.left
        anchors.leftMargin: 0
        anchors.top: parent.top
        anchors.topMargin: 0

        Camera {
            id: camera
            captureMode: Camera.CaptureVideo
            videoRecorder {
            }
            //deviceId: "/dev/video2"
        }

        VideoOutput {
            source: camera
            anchors.fill: parent
        }
    }

    onVisibleChanged: {
        if (!pageCam.visible ) {
            camera.stop()
            console.log("camera stopped")
        } else {
            camera.start()
            console.log("camera started")
        }
    }

    ListView {
        id: deviceView
        anchors.right: parent.right
        anchors.rightMargin: 0
        anchors.left: camRect.right
        anchors.leftMargin: 0
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0
        anchors.top: parent.top
        anchors.topMargin: 0


        model: QtMultimedia.availableCameras
        delegate: Text {
            text: modelData.displayName + " " + modelData.deviceId
            color: "white"
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    console.log("changed camera to", modelData.deviceId);
                    camera.deviceId = modelData.deviceId
                }
            }
        }

    }

}
