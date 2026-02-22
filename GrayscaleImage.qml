import QtQuick 2.15
import QtGraphicalEffects 1.15
import QtMultimedia 5.15

Item {
    id: root

    property url    source
    property int    fillMode:          Image.PreserveAspectFit
    property bool   showBorder:        false
    property color  borderColor:       Qt.rgba(0, 0, 0, 0.30)
    property int    verticalAlignment: Image.AlignVCenter

    property bool muted: true

    readonly property bool isVideo: {
        var s = source.toString().toLowerCase()
        return s.endsWith(".mp4")  || s.endsWith(".mkv")  ||
        s.endsWith(".avi")  || s.endsWith(".webm") ||
        s.endsWith(".mov")  || s.endsWith(".flv")  ||
        s.endsWith(".m4v")
    }

    readonly property real paintedWidth: {
        if (isVideo) {
            var vo = videoLoader.item ? videoLoader.item.videoOut : null
            return vo ? vo.contentRect.width : 0
        }
        return img.paintedWidth
    }
    readonly property real paintedHeight: {
        if (isVideo) {
            var vo = videoLoader.item ? videoLoader.item.videoOut : null
            return vo ? vo.contentRect.height : 0
        }
        return img.paintedHeight
    }

    function calcY() {
        var free = parent.height - img.paintedHeight
        if (verticalAlignment === Image.AlignTop)    return 0
            if (verticalAlignment === Image.AlignBottom) return free
                return free / 2
    }

    readonly property string _grayFrag: "
    uniform sampler2D source;
    uniform lowp float qt_Opacity;
    varying highp vec2 qt_TexCoord0;
    void main() {
    highp vec4 color = texture2D(source, qt_TexCoord0);
    highp float gray = dot(color.rgb, vec3(0.299, 0.587, 0.114));
    gray = clamp((gray - 0.5) * 1.15 + 0.5, 0.0, 1.0);
    gl_FragColor = vec4(vec3(gray), color.a * qt_Opacity);
}
"
Image {
    id: img
    anchors.fill: parent
    visible:      false
    source:       !root.isVideo ? root.source : ""
    fillMode:     root.fillMode
    asynchronous: true
}

ShaderEffect {
    visible:  !root.isVideo
    x:        (parent.width  - img.paintedWidth)  / 2
    y:        root.calcY()
    width:    img.paintedWidth
    height:   img.paintedHeight
    property variant source: img
    fragmentShader: root._grayFrag
}

Loader {
    id: videoLoader
    anchors.fill: parent
    active: root.isVideo

    sourceComponent: Component {
        Item {
            anchors.fill: parent

            property alias videoOut: _videoOut

            MediaPlayer {
                id: _player
                source: root.source
                loops:  MediaPlayer.Infinite
                volume: root.muted ? 0.0 : 0.7
            }

            VideoOutput {
                id: _videoOut
                anchors.fill: parent
                source:       _player
                fillMode:     VideoOutput.PreserveAspectFit
                visible:      false
            }

            ShaderEffectSource {
                id: _videoSrc
                sourceItem: _videoOut
                anchors.fill: _videoOut
                visible: false
                live:    true
            }

            ShaderEffect {
                anchors.fill: _videoOut
                property variant source: _videoSrc
                fragmentShader: root._grayFrag
            }

            Timer {
                interval: 0
                running:  true
                onTriggered: _player.play()
            }

            Component.onDestruction: _player.stop()

            Rectangle {
                anchors.top:   parent.top
                anchors.right: parent.right
                anchors.margins: vpx(8)
                width: vpx(45); height: vpx(45); radius: vpx(5)
                color: muteHover.containsMouse ? Qt.rgba(0,0,0,0.55) : Qt.rgba(0,0,0,0.30)
                Behavior on color { ColorAnimation { duration: 100 } }

                Image {
                    anchors.centerIn: parent
                    width: vpx(34); height: vpx(34)
                    source: root.muted
                    ? "assets/icons/mute.svg"
                    : "assets/icons/volume.svg"
                    fillMode: Image.PreserveAspectFit
                    mipmap: true
                }

                MouseArea {
                    id: muteHover
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.muted = !root.muted
                }
            }
        }
    }
}

Rectangle {
    visible:      root.showBorder && root.paintedWidth > 0
    x:            root.isVideo && videoLoader.item
    ? videoLoader.item.videoOut.contentRect.x
    : (parent.width  - img.paintedWidth) / 2
    y:            root.isVideo && videoLoader.item
    ? videoLoader.item.videoOut.contentRect.y
    : root.calcY()
    width:        root.paintedWidth
    height:       root.paintedHeight
    color:        "transparent"
    border.color: root.borderColor
    border.width: 3
}
}
