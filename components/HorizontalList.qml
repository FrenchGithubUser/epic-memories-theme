import QtQuick 2.3
import QtMultimedia 5.15
import QtGraphicalEffects 1.15

FocusScope {
    id: horizontalList
    property var currentGame: api.collections.get(currentCollectionIndex).games.get(gameView.currentIndex)
    property int listShadowHeight: 150
        property string state: root.state
            property bool playing: false

                width: parent.width
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                Behavior on focus {
                ParallelAnimation {
                    PropertyAnimation {
                        target: background
                        property: "opacity"
                        from: 0
                        to: 1
                        duration: 200
                    }
                    PropertyAnimation {
                        target: gameView
                        property: "anchors.bottomMargin"
                        from: vpx(-300)
                        to: gameView.anchors.bottomMargin
                        duration: 200
                        easing.type: Easing.OutCubic
                    }
                }
            }

            Item {
                id: background
                anchors.fill: parent

                property string bgImage1
                property string bgImage2
                property bool firstBG: true

                    // property var bgData: currentGame
                    property string bgSource: currentGame.assets.background ?? currentGame.assets.screenshot
                        onBgSourceChanged: { if (bgSource != "") swapImage(bgSource) }

                        states: [
                            State { // this will fade in gameBG2 and fade out gameBG1
                                name: "fadeInRect2"
                                PropertyChanges { target: gameBG1; opacity: 0}
                                PropertyChanges { target: gameBG2; opacity: 1}
                            },
                            State   { // this will fade in gameBG1 and fade out gameBG2
                                name:"fadeOutRect2"
                                PropertyChanges { target: gameBG1;opacity:1}
                                PropertyChanges { target: gameBG2;opacity:0}
                            }
                        ]

                        transitions: [
                            Transition {
                                NumberAnimation { property: "opacity"; easing.type: Easing.InOutQuad; duration: 300 }
                            }
                        ]

                        function swapImage(newSource)
                        {
                            if (firstBG)
                            {
                                // Go to second image
                                if (newSource)
                                    bgImage2 = newSource

                                firstBG = false
                            } else {
                            // Go to first image
                            if (newSource)
                                bgImage1 = newSource

                            firstBG = true
                        }
                        background.state = background.state == "fadeInRect2" ? "fadeOutRect2" : "fadeInRect2"
                    }

                    Image{
                        id: gameBG1

                        anchors.fill: parent
                        source: background.bgImage1
                        fillMode: Image.PreserveAspectCrop
                        sourceSize: Qt.size(parent.width, parent.height)
                        // smooth: true
                        asynchronous: true
                        visible: !playing
                    }

                    Image {
                        id: gameBG2

                        anchors.fill: parent
                        source: background.bgImage2
                        fillMode: Image.PreserveAspectCrop
                        sourceSize: Qt.size(parent.width, parent.height)
                        // smooth: true
                        asynchronous: true
                        visible: !playing
                    }
                }

                onCurrentGameChanged: {
                    videoPreviewLoader.sourceComponent = undefined;
                    playing = false
                    videoDelay.restart();
                }

                onPlayingChanged: {
                    playing ? ambiantMusic.pause() : ambiantMusic.play()
                }

                onStateChanged: {
                    videoPreviewLoader.sourceComponent = undefined;
                    videoDelay.restart();
                }

                // Timer to show the video
                Timer {
                    id: videoDelay

                    interval: 2000
                    onTriggered: {
                        if (currentGame && currentGame.assets.videos.length && state === 'games')
                        {
                            videoPreviewLoader.sourceComponent = videoPreviewWrapper;
                            playing = true
                        }
                    }
                }

                Component {
                    id: videoPreviewWrapper

                    Video {
                        id: videocomponent

                        anchors.fill: parent

                        source: currentGame.assets.videoList.length ? currentGame.assets.videoList[0] : ""
                        fillMode: VideoOutput.PreserveAspectFit
                        loops: MediaPlayer.Infinite
                        autoPlay: true
                        visible: currentGame.assets.videoList.length
                        muted: false
                    }
                }
                Item {
                    id: videocontainer

                    anchors.fill: parent

                    Loader {
                        id: videoPreviewLoader
                        asynchronous: true
                        anchors { fill: parent }
                    }
                }

                //shadows
                Item{
                    id: shadows
                    anchors.fill: parent

                    Rectangle{
                        id: listShadow
                        height: vpx(listShadowHeight)
                        anchors.top: parent.bottom
                        anchors.right: parent.right
                        anchors.left: parent.left
                    }
                    DropShadow {
                        anchors.fill: listShadow
                        verticalOffset: -listShadowHeight
                        radius: 100.0
                        samples: 100
                        color: "#90000000"
                        source: listShadow
                    }

                }


                Image {
                    id: gameLogo

                    width: playing ? vpx(100) : vpx(250)

                    Behavior on width { NumberAnimation { duration: 150 } }
                    fillMode: Image.PreserveAspectFit
                    source: currentGame.assets.logo
                    asynchronous: true

                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.leftMargin: vpx(30)
                    anchors.topMargin: vpx(20)
                }

                ListView {
                    id: gameView
                    model: currentCollection.games
                    delegate: gameViewDelegate

                    highlightMoveDuration : 250

                    orientation: ListView.Horizontal
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.margins: vpx(10)
                    height: vpx(200)
                    spacing: vpx(20)
                    keyNavigationWraps: true

                    // highlightRangeMode: ListView.ApplyRange

                    focus: true
                    // clip: true

                    snapMode: ListView.SnapOneItem
                    highlightRangeMode: ListView.StrictlyEnforceRange

                    //sound + change collection if end/beginning reached
                    property int previousListIndex: 0
                        Keys.onLeftPressed: {
                            gameView.decrementCurrentIndex();
                            // if (currentCollectionIndex <= 0 && previousListIndex <= 0)
                            // {
                            //     // currentCollectionIndex = api.collections.count - 1;
                            // }
                            // else if (previousListIndex <= 0)
                            // {
                            //     // currentCollectionIndex--;
                            // }
                            // else
                            // {
                            //     nextGameSfx.play()
                            // }
                            // previousListIndex = gameView.currentIndex
                            nextGameSfx.play()
                        }

                        Keys.onRightPressed: {
                            gameView.incrementCurrentIndex();
                            // if (currentCollectionIndex >= api.collections.count - 1 && previousListIndex >= currentCollection.games.count - 1)
                            // {
                            //     currentCollectionIndex = 0;
                            // }
                            // else if(previousListIndex >= currentCollection.games.count - 1)
                            // {
                            //     currentCollectionIndex++;
                            // }
                            // else
                            // {
                            //     nextGameSfx.play()
                            // }
                            // previousListIndex = gameView.currentIndex
                            nextGameSfx.play()
                        }

                        Keys.onPressed: {
                            if (api.keys.isAccept(event))
                            {
                                event.accepted = true;
                                currentGame.launch()

                            }
                            if (api.keys.isCancel(event))
                            {
                                root.state = 'consoles'
                                event.accepted = true;
                            }

                        }

                    }

                    Component {
                        id: gameViewDelegate


                        Image {
                            id: gameCover

                            // width: ListView.isCurrentItem ? vpx(330): vpx(100)
                            height: ListView.isCurrentItem ? (playing ? vpx(180) :vpx(300)) : vpx(70)

                            fillMode: Image.PreserveAspectFit
                            source: modelData.assets.boxFront
                            asynchronous: true

                            anchors.bottom: parent.bottom
                            anchors.bottomMargin: playing && !ListView.isCurrentItem ? vpx(-100) : 0
                            Behavior on height { NumberAnimation { duration: 150 } }
                            Behavior on anchors.bottomMargin {
                            NumberAnimation {
                                duration: 150
                                easing.type: Easing.OutCubic
                            }
                        }
                    }

                }

                //sounds
                Audio {
                    id: ambiantMusic
                    source: (state === 'games') ? "../assets/sounds/ambiant/" + currentCollection.shortName + ".wav" : ""
                    autoPlay: true
                    loops: Audio.Infinite
                }

            }

