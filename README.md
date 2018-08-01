M.O.C.S
-------

My Own Car System see [this blogpost](https://blog.nobugware.com/post/2018/my_own_car_system_raspberry_pi_offline_mapping/)

This app is an experiment to replace the non existent management system in my car.

It shows a rear camera and a live 3D map.

It's a Go application using [Qt bindings](https://github.com/therecipe/qt)

![Image of Mocs](https://raw.githubusercontent.com/akhenakh/mocs/master/images/mocs.png)

## Build
```
export CGO_CXXFLAGS_ALLOW=".*"
export CGO_LDFLAGS_ALLOW=".*" 
export CGO_CFLAGS_ALLOW=".*"
export QT_PKG_CONFIG=true 
qtdeploy build # if you installed the bindings
qtdeploy -docker build rpi3 # with docker cross compiler image for rpi3
```

## Capture Video
Qt via Gstreamer does not allow non interlaced videos :(  
One solution is to force a pipeline with an interlacer.

```
export QT_GSTREAMER_CAMERABIN_VIDEOSRC="videotestsrc"
```
Not that easy via Qt I had to patch camerabinsession.cpp to insert a filter on the preview:
at the end of `GstElement *CameraBinSession::buildCameraSource()`
```
    const QByteArray envInterlace = qgetenv("QT_GSTREAMER_CAMERABIN_VIDEO_INTERLACE");
    if (envInterlace.length() > 0) {
        GstElement *interlace = gst_element_factory_make ("interlace", NULL);
        if (interlace == NULL)
            g_error ("Could not create 'interlace' element");


        g_object_set(G_OBJECT(m_camerabin), "viewfinder-filter", interlace, NULL);

        #if CAMERABIN_DEBUG
            qDebug() << "set camera filter" << interlace;
        #endif
        gst_object_unref (interlace);
    }
```

## GPS
It reads GPS data from [gpsd](https://github.com/akhenakh/gpsd)

## Offline maps
[OpenMapTiles project is great](https://openmaptiles.org) to generate vector data in MBTILES format, serve them with[mbmatch](https://github.com/akhenakh/mbmatch).  
Qt Map QML can display them using the `mapboxgl` driver.


## Routing

Hopefully the provided Qt `osm` plugins knows how to route using the OSRM API.  
So you can have a local OSRM for routing and it will work.
```
osrm-extract -p /usr/share/osrm/profiles/car.lua quebec-latest.osm.pbf 
osrm-contract quebec-latest.osrm
osrm-routed quebec-latest.osrm
```

## Raspberry
I'm using an Rpi3 (old model).

With [Arch for ARM](https://archlinuxarm.org) but any system will do.

Enable mocs at startup.  
Edit `/lib/systemd/system/mocs.service`


```
[Unit]
Description=Mocs

[Service]
ExecStart=/home/youruser/mocs
Environment=QT_QPA_PLATFORM=eglfs:/dev/fb0
Environment=QT_GSTREAMER_CAMERABIN_VIDEO_INTERLACE=yes
Environment=QT_QPA_EGLFS_HIDECURSOR=yes
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
```
`systemctl --user enable mocs.service`

Enable osrm  

## License
this code is under MIT license

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

But due to Qt and !@# LGPL, licensing of this code is uncertain since Go is compiling static code [see therecipe FAQ](https://github.com/therecipe/qt/wiki/FAQ#what-is-the-implication-from-using-lgpl-library-in-my-go-app-)

