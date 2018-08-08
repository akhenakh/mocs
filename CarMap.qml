import QtQuick 2.4
import QtLocation 5.11
import QtPositioning 5.11
import "fontawesome.js" as FA

Rectangle {
    id: rectMap
    color: "#000000"
    property variant currentPosition

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
            value: "http://localhost:7000/osm-liberty-gl.style,http://localhost:7000/solarized-dark.style"
        }
    }

    Plugin {
        id: routePlugin
        name: "osm"
        locales: ["fr_CA","en_CA", "en_US"]
        PluginParameter{
            name: "osm.routing.host"
            value: "http://localhost:5000/route/v1/driving/"
        }

    }

    Waypoint {
        id: waypointHome
        coordinate: QtPositioning.coordinate(QmlBridge.defaultLat, QmlBridge.defaultLng)
    }

    Timer {
        repeat: false
        running: true
        interval: 4000
        onTriggered: { carMap.copyrightsVisible = false; }
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
        tilt: 10.0
        copyrightsVisible: true

        RouteQuery {
            id: aQuery
        }

        RouteModel {
            id : routeModel
            query: aQuery
            autoUpdate: false
            plugin: routePlugin
        }

        MapItemView {
            id: mapRouteView
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
        color: "#d33682"
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
                //TODO: search
            }
        }
    }

    IconAwesome {
        id: iconHome
        x: parent.width - 70
        y: parent.height - 70
        width: 40
        height: 40
        color: "#6c71c4"
        pointSize: 30
        icon: icons.fa_home;
        MouseArea {
            anchors.fill: parent
            onClicked: {
                if (routeModel.status != RouteModel.Null) {

                    // crash in Qt 5.11
                    // routeModel.reset();
                    aQuery.clearWaypoints();
                    routeModel.cancel();
                    mapRouteView.model = null;

                    console.log("canceling route", routeModel.status);

                    iconHome.icon = FA.Icons.fa_home;
                } else {

                    iconHome.icon = FA.Icons.fa_stop_circle;
                    aQuery.addWaypoint(currentPosition);
                    aQuery.addWaypoint(waypointHome.coordinate);
                    aQuery.travelModes = RouteQuery.CarTravel;
                    mapRouteView.model = routeModel;
                    routeModel.update();
                    console.log("started routing from", currentPosition, "to",  waypointHome.coordinate);
                }
            }
        }
    }

    Connections {
        target: QmlBridge
        onPositionUpdate:
        {
            // offset the car icon
            var screenCenter = carMap.toCoordinate(Qt.point(carMap.width/2, carMap.height/2));
            var bottomCenter = carMap.toCoordinate(Qt.point(carMap.width/2, carMap.height - 60));

            var coord = QtPositioning.coordinate(lat, lng).atDistanceAndAzimuth(
                screenCenter.distanceTo(bottomCenter), heading);

            currentPosition = QtPositioning.coordinate(lat, lng);
             // do not update the heading if low speed
            if (speed > 2) {
                carMap.bearing = heading;
            }
            if (matched) {
                currentPosition = QtPositioning.coordinate(mlat, mlng);
                console.log("matched", mlat, mlng, mheading, roadName)
                coord = QtPositioning.coordinate(mlat, mlng).atDistanceAndAzimuth(
                    screenCenter.distanceTo(bottomCenter), mheading);
                // TODO: no fixed heading so far
                carMap.bearing = mheading;
            }
            carMap.center = coord;
        }
    }
}
