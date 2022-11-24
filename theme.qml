import QtQuick 2.0
import QtMultimedia 5.15
import "components"

FocusScope {
    id: root

    property int currentCollectionIndex: 0
        property var currentCollection: api.collections.get(currentCollectionIndex)
        property var currentGame: currentCollection.games.get(gameList.HorizontalListcurrentIndex)
        property string state: 'consoles'

            ConsolesList{
                id: consolesList

                focus: (root.state === 'consoles')
                opacity: focus
                visible: opacity
            }

            LaunchingConsole{
                id: launchingConsole

                focus: (root.state === 'launching_console')
                opacity: focus
                visible: opacity
            }

            HorizontalList{
                id: gameList

                focus: (root.state === 'games')
                opacity: focus
                visible: opacity
            }

            // todo: move sounds to components
            onStateChanged:{
                if (state === 'consoles')
                {
                    ambiantMusic.stop()
                }
                else if (state === 'games')
                {
                    ambiantMusic.play()
                }
            }


            // sounds
            SoundEffect{
                id:nextGameSfx
                source: "assets/sounds/effects/next/" + currentCollection.shortName + ".wav" ?? ""
            }
            SoundEffect{
                id: nextConsoleSfx
                source: "assets/sounds/effects/next/consoles.wav"
            }
        }


