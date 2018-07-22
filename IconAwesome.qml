import QtQuick 2.6

import "fontawesome.js" as FA

Text {
    id: root;

    property var icons: FA.Icons;
    property alias icon: root.text;
    property alias pointSize: root.font.pointSize;

    font.family: awesome.name;
    style: Text.Normal;
    textFormat: Text.PlainText;
    verticalAlignment: Text.AlignVCenter;
}