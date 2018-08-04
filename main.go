package main

import (
	"context"
	"io"
	"log"
	"os"
	"time"

	"github.com/akhenakh/gpsd/gpssvc"
	google_protobuf "github.com/golang/protobuf/ptypes/empty"
	"github.com/namsral/flag"
	"github.com/therecipe/qt/core"
	"github.com/therecipe/qt/gui"
	"github.com/therecipe/qt/qml"
	"github.com/therecipe/qt/quickcontrols2"
	"google.golang.org/grpc"
)

var (
	gpsAddr = flag.String("gpsAddr", "localhost:9402", "gRPC addr for GPS service")
	lat     = flag.Float64("defaultLat", 46.799059, "latitude for home base")
	lng     = flag.Float64("defaultLng", -71.234126, "longitude for home base")
	debug   = flag.Bool("debug", false, "enable debug")
)

type QmlBridge struct {
	core.QObject
	_ func(lat, lng, heading, speed float64, matched bool, mlat, mlng, mheading float64) `signal:"positionUpdate"`
	_ float64                                                                            `property:"defaultLat"`
	_ float64                                                                            `property:"defaultLng"`
}

func main() {
	log.SetFlags(log.LstdFlags | log.Lshortfile)

	flag.Parse()

	os.Setenv("QT_IM_MODULE", "qtvirtualkeyboard")

	// Create application
	gui.NewQGuiApplication(len(os.Args), os.Args)

	// Use the material style for qml
	quickcontrols2.QQuickStyle_SetStyle("Material")

	var qmlBridge = NewQmlBridge(nil)

	qmlBridge.SetDefaultLat(*lat)
	qmlBridge.SetDefaultLng(*lng)

	// Create a QML application engine
	var app = qml.NewQQmlApplicationEngine(nil)
	app.RootContext().SetContextProperty("QmlBridge", qmlBridge)

	// Load the main qml file
	app.Load(core.NewQUrl3("qrc:/main.qml", 0))

	// read GPS data
	conn, err := grpc.Dial(*gpsAddr, grpc.WithInsecure())
	if err != nil {
		log.Fatal(err)
	}
	gps := gpssvc.NewGPSSVCClient(conn)

	go func() {
		for {
		reconn:
			if *debug {
				log.Println("Connecting to GPSD", *gpsAddr)
			}
			feed, err := gps.LivePosition(context.Background(), &google_protobuf.Empty{})
			if err != nil {
				log.Println(err)
				time.Sleep(1 * time.Second)
				goto reconn
			}
			for {
				p, err := feed.Recv()
				if err == io.EOF {
					log.Println("gps service disconnected")
					time.Sleep(1 * time.Second)
					goto reconn
				}
				if err != nil {
					log.Println(err)
					goto reconn
				}

				qmlBridge.PositionUpdate(p.Latitude, p.Longitude, p.Heading, p.Speed,
					p.Matched, p.MatchedLatitude, p.MatchedLongitude, p.MatchedHeading)
				if *debug {
					log.Println("received via GPSSVC", p)
				}
			}

		}
	}()

	// Execute app
	gui.QGuiApplication_Exec()
}
