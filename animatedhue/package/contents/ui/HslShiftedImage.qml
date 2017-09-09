import QtQuick 2.5

import QtGraphicalEffects 1.0

Item {
    id: shiftedImage

    property alias fillMode: image.fillMode
    property alias source: image.source
    property alias sourceSize: image.sourceSize
    property alias status: image.status

    property alias hue: hueSaturation.hue

    Image {
        id: image
        anchors.fill: parent
        visible: false
        // sourceSize: Qt.size(parent.width, parent.height)
        smooth: true
        asynchronous: true
        cache: false
        autoTransform: true //new API in Qt 5.5, do not backport into Plasma 5.4.
    }
    
    // http://doc.qt.io/qt-5/qml-qtgraphicaleffects-huesaturation.html
    HueSaturation {
        id: hueSaturation
        anchors.fill: parent
        source: image
    }

    // Text {
    //     id: debugText
    //     anchors.fill: parent
    //     color: "#eee"
    //     text: "Hue: " + hueSaturation.hue
    //     font.pixelSize: 24 * units.devicePixelRatio
    // }
}
