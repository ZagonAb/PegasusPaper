import QtQuick 2.15
import QtMultimedia 5.15

Item {
    id: sfx

    property real volume: 0.4
    property bool muted:  false

    function playMove()     { if (!muted) sndMove.play() }
    function playCancel()   { if (!muted) sndCancel.play() }
    function playFavorite() { if (!muted) sndFavorite.play() }

    SoundEffect {
        id: sndMove
        source: "assets/sound/mov.wav"
        volume: sfx.volume
    }

    SoundEffect {
        id: sndCancel
        source: "assets/sound/can.wav"
        volume: sfx.volume
    }

    SoundEffect {
        id: sndFavorite
        source: "assets/sound/fav.wav"
        volume: sfx.volume
    }
}
