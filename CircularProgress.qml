import QtQuick 2.0

// draws two arcs (portion of a circle)
// fills the circle with a lighter secondary color
// when pressed
Canvas {
    id: canvas
    width: 120
    height: 120
    antialiasing: true

    property real centerWidth: width / 2
    property real centerHeight: height / 2
    property real radius: Math.min(canvas.width, canvas.height) / 2

    property real minimumValue: 0
    property real maximumValue: 100
    property real value: 0
    property real displayedValue: 0

    // this is the angle that splits the circle in two arcs
    // first arc is drawn from 0 radians to angle radians
    // second arc is angle radians to 2*PI radians
    property real angle: (displayedValue - minimumValue) / (maximumValue - minimumValue) * 2 * Math.PI

    // we want both circle to start / end at 12 o'clock
    // without this offset we would start / end at 9 o'clock
    property real angleOffset: -Math.PI / 2

    onMinimumValueChanged: requestPaint()
    onMaximumValueChanged: requestPaint()
    onValueChanged:{
        displayedValue = value
        requestPaint()
    }
    onDisplayedValueChanged: requestPaint()
    onOpacityChanged: requestPaint()


    Behavior on displayedValue { NumberAnimation {duration: 50} }

    onPaint: {
        var ctx = getContext("2d");
        ctx.save();

        ctx.clearRect(0, 0, canvas.width, canvas.height);

        // First, thinner arc
        // From angle to 2*PI

        ctx.beginPath();
        ctx.lineWidth = 3;
        ctx.strokeStyle = Qt.rgba(60, 60, 60, opacity);
        ctx.arc(canvas.centerWidth,
                canvas.centerHeight,
                canvas.radius - 4,
                angleOffset + canvas.angle,
                angleOffset + 2*Math.PI);
        ctx.stroke();


        // Second, thicker arc
        // From 0 to angle

        ctx.beginPath();
        ctx.lineWidth = 6;
        ctx.strokeStyle = Qt.rgba(208, 208, 208, opacity);
        ctx.arc(canvas.centerWidth,
                canvas.centerHeight,
                canvas.radius - 4,
                canvas.angleOffset,
                canvas.angleOffset + canvas.angle);
        ctx.stroke();

        ctx.restore();
    }

    Text {
        anchors.centerIn: parent

        text: Math.floor(canvas.displayedValue)
        color: "#909090"
    }
}
