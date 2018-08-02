import QtQuick 2.4
import QtLocation 5.11
import QtPositioning 5.11

Rectangle {
    id: rectMap
    color: "#000000"

    Plugin {
        id: mapPlugin
        name: "mapboxgl" // "mapboxgl", "esri", ...
        locales: ["fr_CA","en_CA"]
        // specify plugin parameters if necessary
        // PluginParameter {
        //     name:
        //     value:
        // }
        PluginParameter{
            name: "mapbox.mapping.additional_map_ids"
            value: "solarized-dark,osm-liberty-gl"
        }
        PluginParameter{
            name: "mapboxgl.mapping.additional_style_urls"
            value: "http://localhost:7000/solarized-dark.style,http://localhost:7000/osm-liberty-gl.style"
        }
    }

    Plugin {
        id: routePlugin
        name: "osm"
        locales: ["fr_CA","en_CA"]
        PluginParameter{
            name: "osm.routing.host"
            value: "http://localhost:5000/route/v1/driving/"
        }

    }

    Waypoint {
        id: waypointStart
        coordinate: QtPositioning.coordinate(46.7852, -71.3256)
        bearing: 3
    }

    Waypoint {
        id: waypointEnd
        coordinate: QtPositioning.coordinate(46.798556, -71.233922)
        bearing: 45
    }

    Map {
        id: carMap
        anchors.fill: parent
        plugin: mapPlugin
        center: QtPositioning.coordinate(QmlBridge.defaultLat, QmlBridge.defaultLng)
        zoomLevel: 19
        gesture.acceptedGestures: MapGestureArea.PanGesture | MapGestureArea.FlickGesture | MapGestureArea.PinchGesture | MapGestureArea.RotationGesture | MapGestureArea.TiltGesture
        gesture.flickDeceleration: 3000
        gesture.enabled: true
        //tilt: 45.0
        copyrightsVisible: false
        RouteQuery {
            id: aQuery
        }

        RouteModel {
            id : routeModel
            query: aQuery
            autoUpdate: true
            plugin: routePlugin
        }

        MapItemView {
            model: routeModel
            delegate: routeDelegate
        }

        Component {
            id: routeDelegate

            MapRoute {
                route: routeData
                line.color: "#d33682"
                line.width: 7
                smooth: true
                opacity: 1.0
            }
        }
        ListView {
            id: listview
            anchors.fill: parent
            spacing: 10
            model: routeModel.status == RouteModel.Ready ? routeModel.get(0).segments : null
            //visible: model ? true : false
            visible: false
            delegate: Row {
                width: parent.width
                spacing: 10
                property bool hasManeuver : modelData.maneuver && modelData.maneuver.valid
                visible: hasManeuver
                Text { text: (1 + index) + "." }
                Text { text: hasManeuver ? modelData.maneuver.instructionText : "" }
            }
        }

        Behavior on center {
            CoordinateAnimation {
                duration: 990
                easing.type: Easing.Linear
            }
        }

        Behavior on bearing {
            RotationAnimation {
                duration: 990
                easing.type: Easing.Linear
            }
        }
    }

    IconAwesome {
        id: iconCar
        x: carMap.width/2 - 10
        y: carMap.height - 80 
        width: 40
        height: 40
        color: "#dc322f"
        pointSize: 40
        icon: icons.fa_arrow_up;
    }
    
    IconAwesome {
        id: iconSun
        x: parent.width - 70
        y: 30
        width: 40
        height: 40
        color: "#6c71c4"
        pointSize: 30
        icon: icons.fa_adjust;
        MouseArea {
            anchors.fill: parent
            onClicked: { 
                if (carMap.activeMapType === carMap.supportedMapTypes[0]) { carMap.activeMapType = carMap.supportedMapTypes[1] } else { carMap.activeMapType = carMap.supportedMapTypes[0]}
            }
        }
    }

    IconAwesome {
        id: iconSearch
        x: parent.width - 70
        y: 120
        width: 40
        height: 40
        color: "#6c71c4"
        pointSize: 30
        icon: icons.fa_search;
        MouseArea {
            anchors.fill: parent
            onClicked: { 
                if (carMap.activeMapType === carMap.supportedMapTypes[0]) { carMap.activeMapType = carMap.supportedMapTypes[1] } else { carMap.activeMapType = carMap.supportedMapTypes[0]}
            }
        }
    }

    Connections {
        target: QmlBridge
        onPositionUpdate: 
        {   
            // offset the 
            var screenCenter = carMap.toCoordinate(Qt.point(carMap.width/2, carMap.height/2));
            var bottomCenter = carMap.toCoordinate(Qt.point(carMap.width/2, carMap.height - 40));
            
            var coord = QtPositioning.coordinate(lat, lng).atDistanceAndAzimuth(
                screenCenter.distanceTo(bottomCenter), heading);
            
            if (matched) {
                console.log("matched", mlat, mlng, mheading)
                coord = QtPositioning.coordinate(mlat, mlng).atDistanceAndAzimuth(
                screenCenter.distanceTo(bottomCenter), mheading);
                 // do not update the heading if low speed
                if (speed > 1) {
                    carMap.bearing = mheading;
                }
            }
            carMap.center = coord;
            // do not update the heading if low speed
            if (speed > 1) {
                carMap.bearing = heading;
            }
        }
    }
}
