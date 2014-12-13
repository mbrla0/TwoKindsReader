import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Window 2.0

Item {
    id: root

    // Aliases
    property alias source: image.source
    property alias status: image.status

    // The main image
    Image {
        id: image
        fillMode: Image.PreserveAspectFit
        anchors.fill: parent
        state: "loading"
        smooth: true

        // States and transitions
        states: [
            State {
                name: "loading"
                PropertyChanges {target: image; opacity: 0}
            },
            State {
                name: "done"
                PropertyChanges {target: image; opacity: 1}
            }
        ]
        Behavior on opacity { PropertyAnimation {} }

        // Signals
        onSourceChanged:   {load_progress.value = 0; load_progress.state = "default"; image.state = "loading"}
        onProgressChanged: {load_progress.value = image.progress * 100; if(load_progress.value === 100){ load_progress.state = "done"; image.state = "done" }}
    }

    // The image's load progress bar
    CircularProgress{
        id: load_progress
        state: "default"
        anchors{
            centerIn: parent
            left: parent.left
            right: parent.right
            margins: parent.width / 4
        }

        // States and transitions

        states:[
            State {
                name: "done"
                PropertyChanges {target: load_progress; opacity: 0}
            },
            State {
                name: "default"
                PropertyChanges {target: load_progress; opacity: 1}
            }

        ]
        Behavior on opacity { PropertyAnimation {} }
    }
}
