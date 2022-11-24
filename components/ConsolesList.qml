import QtQuick 2.3
import QtMultimedia 5.15
import QtGraphicalEffects 1.15

FocusScope {
    id: consolesList
    property var currentConsole: api.collections.get(currentCollectionIndex)
    property int listShadowHeight: 150
        property string state: root.state
            property bool playing

            anchors.fill: parent

            Item {
                id: background

                anchors.fill: parent

                property string bgImage1
                property string bgImage2
                property bool firstBG: true

                    // property var bgData: currentConsole
                    property string bgSource: "../assets/images/console-arts/" + currentConsole.shortName + ".png"
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

                    Image {
                        id: gameBG1

                        anchors.fill: parent
                        source: background.bgImage1
                        fillMode: Image.PreserveAspectCrop
                        sourceSize: Qt.size(parent.width, parent.height)
                        // smooth: true
                        asynchronous: true
                    }

                    Image {
                        id: gameBG2

                        anchors.fill: parent
                        source: background.bgImage2
                        fillMode: Image.PreserveAspectCrop
                        sourceSize: Qt.size(parent.width, parent.height)
                        // smooth: true
                        asynchronous: true
                    }
                }



                onCurrentConsoleChanged: {
                    videoPreviewLoader.sourceComponent = undefined;
                    videoDelay.restart();
                }

                onPlayingChanged: {
                    videoPreviewLoader.sourceComponent = undefined;
                    videoDelay.restart();
                }

                onStateChanged: {
                    videoPreviewLoader.sourceComponent = undefined;
                    videoDelay.restart();
                }


                property string videoSource: "../assets/videos/consoles/" + currentConsole.shortName + ".mp4"
                    // Timer to show the video
                    Timer {
                        id: videoDelay

                        interval: 1500
                        onTriggered: {
                            if (currentConsole && videoSource && root.state === 'consoles')
                            {
                                videoPreviewLoader.sourceComponent = videoPreviewWrapper;
                            }
                        }
                    }

                    Component {
                        id: videoPreviewWrapper

                        //todo: only load video size corresponding to screen size
                        Video {
                            id: videocomponent

                            anchors.fill: parent
                            source: videoSource ?? ""
                            fillMode: VideoOutput.PreserveAspectFit
                            loops: MediaPlayer.Infinite
                            autoPlay: true
                            visible: videoSource
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

                        width: vpx(250)
                        fillMode: Image.PreserveAspectFit
                        source: currentConsole.assets.logo
                        asynchronous: true

                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.leftMargin: vpx(30)
                        anchors.topMargin: vpx(20)
                    }

                    ListView {
                        id: consoleView
                        model: api.collections
                        delegate: consoleViewDelegate

                        highlightMoveDuration : 100

                        orientation: ListView.Horizontal
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.margins: vpx(10)
                        anchors.leftMargin: vpx(-20)
                        height: vpx(200)
                        focus: true
                        // clip: true

                        snapMode: ListView.SnapOneItem
                        highlightRangeMode: ListView.StrictlyEnforceRange

                        keyNavigationWraps: true
                        //sound + loop if end/beginning reached
                        property int previousListIndex: 0
                            Keys.onLeftPressed: {
                                consoleView.decrementCurrentIndex();
                                if (currentCollectionIndex <= 0 && previousListIndex <= 0)
                                {
                                    currentCollectionIndex = api.collections.count - 1;
                                    consoleView.currentIndex = api.collections.count - 1
                                }
                                else{
                                    currentCollectionIndex--
                                }
                                previousListIndex = consoleView.currentIndex

                                nextConsoleSfx.play()
                            }

                            Keys.onRightPressed: {
                                consoleView.incrementCurrentIndex();
                                if (currentCollectionIndex >= api.collections.count - 1)
                                {
                                    currentCollectionIndex = 0;
                                    consoleView.currentIndex = 0
                                }
                                else{
                                    currentCollectionIndex++
                                }
                                previousListIndex = consoleView.currentIndex

                                nextConsoleSfx.play()
                            }
                            Keys.onPressed:{
                                if (api.keys.isAccept(event))
                                {
                                    root.state = 'launching_console'
                                    event.accepted = true;
                                }
                            }

                        }

                        Component {
                            id: consoleViewDelegate

                            Image {
                                id: consoleController

                                // height: ListView.isCurrentItem ? vpx(300) : vpx(70)
                                width: ListView.isCurrentItem ? vpx(250) : vpx(70)

                                fillMode: Image.PreserveAspectFit
                                source: "../assets/images/controllers/" + modelData.shortName + ".png"
                                asynchronous: true

                                anchors.bottom: parent.bottom
                                Behavior on height { NumberAnimation { duration: 100 } }
                            }


                        }

                    }

