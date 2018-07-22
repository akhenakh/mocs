import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.3
import QtQuick.VirtualKeyboard 2.3
import QtPositioning 5.11

ApplicationWindow {
    id: window
    visible: true
    width: 1024 
    height: 600 
    title: qsTr("Tabs")

    Material.theme: Material.Dark
    Material.accent: Material.Indigo
    Material.background: "black"
   
    FontLoader
    {
        id: robotoLight
        source: "./fonts/Roboto-Light.ttf"
    }

    FontLoader
    {
        id: awesome
        source: "./fonts/fontawesome-webfont.ttf"
    }

    SwipeView {
        id: swipeView
        anchors.fill: parent
        currentIndex: tabBar.currentIndex

        onCurrentIndexChanged: {
            // disable the swipe on map
           if (currentIndex == 3) {
               interactive = false
           } else {
               interactive = true
           }
        }

        PageInfo {
        }

        PageData {

        }

        PageCam {
            id: pageCam
        }

        CarMap {
        }
    }


    footer: TabBar {
        id: tabBar
        currentIndex: swipeView.currentIndex

        TabButton {
            text: qsTr("Infos")
        }
        TabButton {
            text: qsTr("Data")
        }
        TabButton {
            text: qsTr("Cam")
        }
        TabButton {
            text: qsTr("Map")
        }

    }

    InputPanel {
        id: inputPanel
        z: 99
        x: 0
        y: window.height
        width: window.width

        states: State {
            name: "visible"
            when: inputPanel.active
            PropertyChanges {
                target: inputPanel
                y: window.height - inputPanel.height
            }
        }
        transitions: Transition {
            from: ""
            to: "visible"
            reversible: true
            ParallelAnimation {
                NumberAnimation {
                    properties: "y"
                    duration: 250
                    easing.type: Easing.InOutQuad
                }
            }
        }
    }
}
