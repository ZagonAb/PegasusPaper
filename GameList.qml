import QtQuick 2.15
import "util.js" as Util

Item {
    id: root

    property var collectionModel: null
    property var currentGame:     null

    property color bgColor
    property color inkBlack
    property color inkDark
    property color inkMid
    property color inkLight
    property color inkFaint
    property color divColor
    property bool  hasFocus: false

    SoundManager { id: sfx }

    signal requestFocus()
    signal requestBack()
    signal toggleTheme()

    function moveUp() {
        var next = Math.max(0, list.currentIndex - 1)
        list.currentIndex = next
        savedIndex = next
    }
    function moveDown() {
        var next = Math.min(list.count - 1, list.currentIndex + 1)
        list.currentIndex = next
        savedIndex = next
    }
    function launchCurrent()  { if (currentGame) currentGame.launch() }
    function toggleFavorite() { if (currentGame) currentGame.favorite = !currentGame.favorite }

    property int savedIndex: 0

    onHasFocusChanged: {
        if (hasFocus) {
            savedIndex = 0
            list.currentIndex = 0
        } else {
            list.currentIndex = -1
        }
    }

    onCollectionModelChanged: {
        savedIndex = 0
        currentGame = (collectionModel && collectionModel.games.count > 0)
        ? collectionModel.games.get(0) : null
    }

    Rectangle { anchors.fill: parent; color: bgColor }

    Item {
        id: panelHeader
        x: 0; y: 0
        width: parent.width
        height: vpx(52)

        Text {
            anchors.left: parent.left
            anchors.leftMargin: vpx(24)
            anchors.verticalCenter: parent.verticalCenter
            text: "GAMES"
            font.family: global.fonts.condensed
            font.pixelSize: vpx(11)
            font.letterSpacing: vpx(4)
            color: inkFaint
        }

        Text {
            anchors.right: parent.right
            anchors.rightMargin: vpx(24)
            anchors.verticalCenter: parent.verticalCenter
            text: collectionModel ? collectionModel.games.count : "0"
            font.family: global.fonts.condensed
            font.pixelSize: vpx(11)
            color: inkFaint
        }

        Rectangle {
            anchors.bottom: parent.bottom
            width: parent.width; height: 1
            color: divColor
        }
    }

    ListView {
        id: list
        x: 0
        y: panelHeader.height
        width: parent.width
        height: parent.height - panelHeader.height
        model: collectionModel ? collectionModel.games : null
        clip: true
        highlightMoveDuration: 100
        keyNavigationEnabled: false
        focus: false

        onModelChanged: {
            if (!root.hasFocus) currentIndex = -1
        }

        onCurrentIndexChanged: {
            if (currentIndex >= 0) {
                var g = model ? model.get(currentIndex) : null
                if (g) {
                    currentGame = g
                    savedIndex = currentIndex
                }
            }
        }

        delegate: Item {
            id: del
            width: list.width
            height: vpx(80)

            readonly property bool isSelected: ListView.isCurrentItem

            Rectangle {
                x: 0; y: 0
                width: isSelected ? vpx(4) : 0
                height: parent.height
                color: inkBlack
                Behavior on width { NumberAnimation { duration: 100 } }
            }

            Rectangle {
                anchors.fill: parent
                color: isSelected ? Qt.rgba(0, 0, 0, 0.06) : "transparent"
                Behavior on color { ColorAnimation { duration: 100 } }
            }

            Item {
                id: thumbArea
                anchors.left: parent.left
                anchors.leftMargin: vpx(12)
                anchors.verticalCenter: parent.verticalCenter
                width: vpx(55)
                height: vpx(68)

                GrayscaleImage {
                    anchors.fill: parent
                    source: modelData.assets.boxFront || modelData.assets.screenshot || ""
                    fillMode: Image.PreserveAspectFit
                    visible: source !== ""
                    opacity: isSelected ? 1.0 : 0.55
                    Behavior on opacity { NumberAnimation { duration: 120 } }
                }
            }

            Column {
                anchors.left: thumbArea.right
                anchors.leftMargin: vpx(12)
                anchors.right: favIcon.left
                anchors.rightMargin: vpx(6)
                anchors.verticalCenter: parent.verticalCenter
                spacing: vpx(5)

                Text {
                    width: parent.width
                    text: Util.cleanGameTitle(modelData.title)
                    font.family: global.fonts.sans
                    font.pixelSize: isSelected ? vpx(16) : vpx(14)
                    font.bold: isSelected
                    color: isSelected ? inkBlack : inkMid
                    elide: Text.ElideRight
                    Behavior on font.pixelSize { NumberAnimation { duration: 100 } }
                }

                Text {
                    width: parent.width
                    text: Util.buildMeta(modelData)
                    font.family: global.fonts.condensed
                    font.pixelSize: vpx(11)
                    color: inkLight
                    elide: Text.ElideRight
                    visible: text !== ""
                }

                Item {
                    width: vpx(60)
                    height: vpx(3)
                    visible: modelData.rating > 0

                    Rectangle { anchors.fill: parent; color: inkFaint; radius: 1 }
                    Rectangle {
                        width: parent.width * modelData.rating
                        height: parent.height
                        color: isSelected ? inkBlack : inkMid
                        radius: 1
                    }
                }
            }

            Text {
                id: favIcon
                anchors.right: parent.right
                anchors.rightMargin: vpx(14)
                anchors.verticalCenter: parent.verticalCenter
                text: "♥"
                font.pixelSize: vpx(12)
                color: isSelected ? inkMid : inkFaint
                visible: modelData.favorite
            }

            Rectangle {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.leftMargin: vpx(4)
                width: parent.width - vpx(8)
                height: 1
                color: divColor
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    root.requestFocus()
                    sfx.playMove()
                    list.currentIndex = index
                    savedIndex = index
                }
                onDoubleClicked: {
                    list.currentIndex = index
                    sfx.playMove()
                    savedIndex = index
                    if (currentGame) currentGame.launch()
                }
            }
        }
    }

    Rectangle {
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.topMargin: panelHeader.height
        width: vpx(2)
        height: parent.height - panelHeader.height
        color: divColor
        visible: list.count > 0

        Rectangle {
            y: list.count > 0
            ? (list.contentY / Math.max(1, list.contentHeight)) * parent.height : 0
            width: parent.width
            height: list.count > 0
            ? Math.max(vpx(16),
                       (list.height / Math.max(1, list.contentHeight)) * parent.height)
            : 0
            color: inkFaint
            radius: 1
        }
    }

    Text {
        anchors.centerIn: parent
        text: "No games in this collection"
        font.family: global.fonts.condensed
        font.pixelSize: vpx(14)
        font.letterSpacing: vpx(2)
        color: inkFaint
        visible: !collectionModel || collectionModel.games.count === 0
    }
}
