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

            HorizontalList{
                id: gameList

                focus: (root.state === 'games')
                opacity: focus
                visible: opacity
            }

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
            Audio {
                id: ambiantMusic
                source: (state === "games" && "assets/sounds/ambiant/" + currentCollection.shortName + ".wav") ? "assets/sounds/ambiant/" + currentCollection.shortName + ".wav" : ""
                autoPlay: true
                loops: Audio.Infinite
            }
            SoundEffect{
                id:nextGameSfx
                source: "assets/sounds/effects/next/" + currentCollection.shortName + ".wav"
            }
            SoundEffect{
                id: nextConsoleSfx
                source: "assets/sounds/effects/next/consoles.wav"
            }
        }


