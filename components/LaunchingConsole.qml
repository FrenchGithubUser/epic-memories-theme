import QtQuick 2.3
import QtMultimedia 5.15


FocusScope {
    id: launchingConsole
    property string state: root.state
        onStateChanged:{
            if (state === 'launching_console')
            {
                consoleStartupVideo.source === "" ? root.state = "games" : consoleStartupVideo.play()
            }
        }

        anchors.fill: parent

        Video {
            id: consoleStartupVideo

            anchors.fill: parent
            source: "../assets/videos/console-intros/" + root.currentCollection.shortName + ".mkv" || ""
            fillMode: VideoOutput.PreserveAspectFit
            autoPlay: false
            visible: true
            onStopped:{root.state = 'games'}
        }

        Keys.onPressed:{
            if (api.keys.isAccept(event))
            {
                root.state = 'games'
                consoleStartupVideo.stop()
                event.accepted = true;
            }
        }
    }