import QtQuick 2.5

HslShiftedImage {
    id: shiftedImage

    property int animationDuration: 400
    property int tickInterval: 1000
    property double tickDelta: 0.05
    property alias running: timer.running

    Behavior on hue {
        NumberAnimation { duration: animationDuration }
    }

    Timer {
        id: timer
        interval: tickInterval
        running: true
        repeat: true
        onTriggered: {
            shiftedImage.hue += tickDelta
        }
    }
}
