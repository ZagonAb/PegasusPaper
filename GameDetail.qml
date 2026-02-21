import QtQuick 2.15
import QtGraphicalEffects 1.15
import "qrc:/qmlutils" as PegasusUtils
import "util.js" as Util

Item {
    id: root

    property var game: null

    property color bgColor
    property color inkBlack
    property color inkDark
    property color inkMid
    property color inkLight
    property color inkFaint
    property color divColor

    SoundManager { id: sfx }

    Rectangle { anchors.fill: parent; color: bgColor }

    Text {
        anchors.centerIn: parent
        text: "← Select a game"
        font.family: global.fonts.condensed
        font.pixelSize: vpx(14)
        font.letterSpacing: vpx(3)
        color: inkFaint
        visible: !game
    }

    Item {
        anchors.fill: parent
        visible: game !== null
        opacity: game ? 1.0 : 0.0
        Behavior on opacity { NumberAnimation { duration: 200 } }

        Flickable {
            id: scroller
            anchors.fill: parent
            contentHeight: contentCol.height + vpx(80)
            clip: true

            MouseArea {
                anchors.fill: parent
                propagateComposedEvents: true
                onWheel: {
                    scroller.contentY = Math.max(0,
                                                 Math.min(scroller.contentHeight - scroller.height,
                                                          scroller.contentY - wheel.angleDelta.y * 0.5))
                }
                onClicked: mouse.accepted = false
            }

            Column {
                id: contentCol
                x: 0; y: 0
                width: parent.width
                spacing: 0

                Item {
                    id: artZone
                    width: parent.width
                    height: vpx(350)
                    clip: true

                    GrayscaleImage {
                        anchors.fill: parent
                        source: game ? (game.assets.background
                        || game.assets.screenshot
                        || game.assets.titlescreen
                        || "") : ""
                        fillMode: Image.PreserveAspectCrop
                        opacity: 0.45
                    }

                    Rectangle {
                        id: fadepaper
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        height: parent.height * 0.55
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: "transparent" }
                            GradientStop { position: 1.0; color: bgColor }
                        }
                    }

                    Item {
                        id: boxHolder
                        anchors.left: parent.left
                        anchors.leftMargin: vpx(15)
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: vpx(5)
                        width: vpx(200)
                        height: vpx(250)
                        visible: game && game.assets.boxFront !== ""

                        GrayscaleImage {
                            anchors.fill: parent
                            source: game ? (game.assets.boxFront || "") : ""
                            fillMode: Image.PreserveAspectFit
                            verticalAlignment: Image.AlignBottom
                            showBorder: true
                        }
                    }

                    Column {
                        anchors.left: boxHolder.visible ? boxHolder.right : parent.left
                        anchors.leftMargin: boxHolder.visible ? vpx(20) : vpx(32)
                        anchors.right: parent.right
                        anchors.rightMargin: vpx(24)
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: vpx(5)
                        spacing: vpx(8)

                        Item {
                            width: parent.width
                            height: vpx(72)

                            Rectangle {
                                id: launchBtn
                                anchors.left: parent.left
                                anchors.leftMargin: vpx(3)
                                anchors.verticalCenter: parent.verticalCenter
                                width: vpx(160)
                                height: vpx(40)
                                color: btnMouse.containsMouse ? inkBlack : "transparent"
                                border.color: inkBlack
                                border.width: 2
                                Behavior on color { ColorAnimation { duration: 120 } }

                                Text {
                                    anchors.centerIn: parent
                                    text: "▶  PLAY"
                                    font.family: global.fonts.condensed
                                    font.pixelSize: vpx(13)
                                    font.letterSpacing: vpx(3)
                                    color: btnMouse.containsMouse ? bgColor : inkBlack
                                    Behavior on color { ColorAnimation { duration: 120 } }
                                }

                                MouseArea {
                                    id: btnMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        sfx.playMove()
                                        if (game) game.launch()
                                    }
                                }
                            }

                            Rectangle {
                                id: favBtn
                                anchors.left: launchBtn.right
                                anchors.leftMargin: vpx(10)
                                anchors.verticalCenter: parent.verticalCenter
                                width: vpx(44)
                                height: vpx(40)
                                color: favMouse.containsMouse
                                ? (game && game.favorite ? inkBlack : inkFaint)
                                : "transparent"
                                border.color: game && game.favorite ? inkBlack : inkFaint
                                border.width: 2
                                Behavior on color { ColorAnimation { duration: 120 } }

                                Image {
                                    id: favIcon
                                    anchors.centerIn: parent
                                    width: vpx(20)
                                    height: vpx(20)
                                    source: (game && game.favorite)
                                    ? "assets/icons/heart_full.svg"
                                    : "assets/icons/heart_broken.svg"
                                    sourceSize: Qt.size(vpx(20), vpx(20))
                                    visible: false
                                }

                                ColorOverlay {
                                    anchors.fill: favIcon
                                    source: favIcon
                                    color: (game && game.favorite)
                                    ? (favMouse.containsMouse ? bgColor : inkBlack)
                                    : (favMouse.containsMouse ? bgColor : inkFaint)
                                    Behavior on color { ColorAnimation { duration: 120 } }
                                }

                                MouseArea {
                                    id: favMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        sfx.playFavorite()
                                        if (game) game.favorite = !game.favorite
                                    }
                                }
                            }

                            Text {
                                anchors.left: favBtn.right
                                anchors.leftMargin: vpx(14)
                                anchors.verticalCenter: parent.verticalCenter
                                font.family: global.fonts.condensed
                                font.pixelSize: vpx(12)
                                font.letterSpacing: vpx(2)
                                color: inkMid
                                text: game && game.playTime > 0 ? formatTime(game.playTime) : ""
                                visible: text !== ""

                                function formatTime(s) {
                                    var h = Math.floor(s / 3600)
                                    var m = Math.floor((s % 3600) / 60)
                                    return h > 0 ? h + "h " + m + "m played" : m + " min played"
                                }
                            }
                        }

                        Text {
                            width: parent.width
                            text: game ? Util.cleanGameTitle(game.title) : ""
                            font.family: global.fonts.sans
                            font.pixelSize: vpx(24)
                            font.bold: true
                            color: inkBlack
                            wrapMode: Text.WordWrap
                        }

                        Text {
                            width: parent.width
                            text: game ? Util.buildMeta(game) : ""
                            font.family: global.fonts.condensed
                            font.pixelSize: vpx(14)
                            font.letterSpacing: vpx(1)
                            color: inkMid
                            wrapMode: Text.WordWrap
                            visible: text !== ""
                        }

                        Row {
                            spacing: vpx(3)
                            visible: game && game.rating > 0
                            Repeater {
                                model: 5
                                Text {
                                    text: (game && index < Math.round(game.rating * 5)) ? "★" : "☆"
                                    font.pixelSize: vpx(14)
                                    color: (game && index < Math.round(game.rating * 5))
                                    ? inkBlack : inkMid
                                }
                            }

                            Text {
                                text: "  •  ♥ FAVORITE"
                                font.family: global.fonts.condensed
                                font.pixelSize: vpx(12)
                                font.letterSpacing: vpx(3)
                                color: inkMid
                                anchors.verticalCenter: parent.verticalCenter
                                visible: game && game.favorite
                            }
                        }
                    }
                }

                Rectangle { width: parent.width; height: 1; color: divColor }

                Grid {
                    x: vpx(32)
                    width: parent.width - vpx(64)
                    columns: 2
                    columnSpacing: 0
                    rowSpacing: 0

                    Repeater {
                        model: [
                            { label: "DEVELOPER",  value: game ? game.developer  : "" },
                            { label: "PUBLISHER",  value: game ? game.publisher  : "" },
                            { label: "GENRE",      value: game ? game.genre      : "" },
                            { label: "PLAYERS",    value: game && game.players > 1
                                ? "1 – " + game.players
                                : (game ? "1" : "") },
                                { label: "RELEASED",   value: game && game.releaseYear > 0
                                    ? game.releaseYear : "" },
                                    { label: "PLAY COUNT", value: game ? game.playCount  : "" },
                        ]

                        delegate: Item {
                            width: parent.width / 2
                            height: modelData.value !== "" ? vpx(54) : 0
                            visible: modelData.value !== ""

                            Column {
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: vpx(2)

                                Text {
                                    text: modelData.label
                                    font.family: global.fonts.condensed
                                    font.pixelSize: vpx(12)
                                    font.letterSpacing: vpx(3)
                                    color: inkFaint
                                }
                                Text {
                                    width: parent.width
                                    text: modelData.value
                                    font.family: global.fonts.sans
                                    font.pixelSize: vpx(16)
                                    color: inkMid
                                    elide: Text.ElideRight
                                }
                            }

                            Rectangle {
                                anchors.bottom: parent.bottom
                                width: parent.width - vpx(8)
                                height: 1
                                color: divColor
                                visible: parent.visible
                            }
                        }
                    }
                }

                Item {
                    width: parent.width
                    height: vpx(180)

                    visible: game && (game.description || game.summary)

                    Rectangle {
                        anchors.fill: parent
                        color: "transparent"

                        Rectangle {
                            anchors.bottom: parent.bottom
                            width: parent.width
                            height: 1
                            color: divColor
                        }
                    }

                    Item {
                        id: scrollContainer
                        anchors {
                            left: parent.left
                            leftMargin: vpx(32)
                            right: parent.right
                            rightMargin: vpx(32)
                            top: parent.top
                            topMargin: vpx(10)
                            bottom: parent.bottom
                            bottomMargin: vpx(10)
                        }
                        clip: true

                        PegasusUtils.AutoScroll {
                            id: autoscroll
                            anchors.fill: parent
                            pixelsPerSecond: 12
                            scrollWaitDuration: 2500

                            Item {
                                width: autoscroll.width
                                height: textColumn.height

                                Column {
                                    id: textColumn
                                    width: parent.width
                                    spacing: vpx(10)

                                    Text {
                                        width: parent.width
                                        text: game ? game.summary : ""
                                        font.family: global.fonts.sans
                                        font.pixelSize: vpx(16)
                                        font.bold: true
                                        color: inkDark
                                        wrapMode: Text.WordWrap
                                        lineHeight: 1.3
                                        visible: text !== ""
                                    }

                                    Text {
                                        width: parent.width
                                        text: game ? game.description : ""
                                        font.family: global.fonts.sans
                                        font.pixelSize: vpx(16)
                                        color: inkMid
                                        wrapMode: Text.WordWrap
                                        lineHeight: 1.5
                                        visible: text !== ""
                                    }
                                }
                            }
                        }
                    }

                    Rectangle {
                        anchors {
                            right: parent.right
                            rightMargin: vpx(16)
                            bottom: parent.bottom
                            bottomMargin: vpx(8)
                        }
                        width: vpx(24)
                        height: vpx(24)
                        radius: vpx(12)
                        color: inkFaint
                        opacity: (autoscroll.atYEnd || !autoscroll.contentHeightExceeds) ? 0 : 0.3
                        Behavior on opacity { NumberAnimation { duration: 300 } }

                        Text {
                            anchors.centerIn: parent
                            text: "▼"
                            font.pixelSize: vpx(10)
                            color: bgColor
                            rotation: autoscroll.scrollDown ? 180 : 0
                            Behavior on rotation { NumberAnimation { duration: 300 } }
                        }
                    }
                }
            }
        }

        Rectangle {
            anchors.right: parent.right
            anchors.top: parent.top
            width: vpx(2)
            height: parent.height
            color: divColor

            Rectangle {
                y: scroller.contentHeight > 0
                ? (scroller.contentY / scroller.contentHeight) * parent.height : 0
                width: parent.width
                height: Math.max(vpx(16),
                                 (scroller.height / Math.max(1, scroller.contentHeight)) * parent.height)
                color: inkFaint
                radius: 1
            }
        }
    }
}
