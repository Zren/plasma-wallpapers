import QtQuick 2.5

import QtGraphicalEffects 1.0

Item {
    id: blurredImage

    property alias fillMode: image.fillMode
    property alias source: image.source
    property alias sourceSize: image.sourceSize
    property alias status: image.status

    property alias blurRadius: blur.radius

    property int animationDuration: 400

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
    
    // http://doc.qt.io/qt-5/qml-qtgraphicaleffects-fastblur.html
    FastBlur {
        id: blur
        anchors.fill: parent
        source: image

        Behavior on radius {
            NumberAnimation { duration: animationDuration }
        }
    }

    // Text {
    //     id: debugText
    //     anchors.fill: parent
    //     color: "#eee"
    //     text: "Blur Radius: " + blurredImage.blurRadius
    //     font.pixelSize: 24 * units.devicePixelRatio
    // }
}
