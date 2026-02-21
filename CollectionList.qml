import QtQuick 2.15
import QtGraphicalEffects 1.15

Item {
    id: root

    property var currentCollection: null

    property color bgColor
    property color inkBlack
    property color inkDark
    property color inkMid
    property color inkLight
    property color inkFaint
    property color divColor
    property bool  hasFocus: false

    signal requestFocus()
    signal collectionChosen()

    SoundManager { id: sfx }

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

    property int savedIndex: 0

    onHasFocusChanged: {
        if (hasFocus) {
            list.currentIndex = savedIndex
        } else {
            list.currentIndex = -1
        }
    }

    Component.onCompleted: {
        if (api.collections.count > 0) {
            savedIndex = 0
            list.currentIndex = hasFocus ? 0 : -1
            currentCollection = api.collections.get(0)
        }
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
            text: "COLLECTIONS"
            font.family: global.fonts.condensed
            font.pixelSize: vpx(11)
            font.letterSpacing: vpx(4)
            color: inkFaint
        }

        Text {
            anchors.right: parent.right
            anchors.rightMargin: vpx(24)
            anchors.verticalCenter: parent.verticalCenter
            text: api.collections.count
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
        model: api.collections
        clip: true
        highlightMoveDuration: 120
        keyNavigationEnabled: false
        focus: false

        onCurrentIndexChanged: {
            if (currentIndex >= 0) {
                var col = model.get(currentIndex)
                if (col) {
                    currentCollection = col
                    savedIndex = currentIndex
                }
            }
        }

        delegate: Item {
            id: del
            width: list.width
            height: vpx(64)

            readonly property bool isSelected: ListView.isCurrentItem

            Rectangle {
                x: 0; y: 0
                width: isSelected ? vpx(4) : 0
                height: parent.height
                color: inkBlack
                Behavior on width { NumberAnimation { duration: 120 } }
            }

            Rectangle {
                anchors.fill: parent
                color: isSelected ? Qt.rgba(0, 0, 0, 0.07) : "transparent"
                Behavior on color { ColorAnimation { duration: 120 } }
            }

            Item {
                id: logoSlot
                anchors.left: parent.left
                anchors.leftMargin: vpx(12)
                anchors.verticalCenter: parent.verticalCenter
                width: vpx(40)
                height: vpx(40)

                Image {
                    id: sysLogo
                    anchors.fill: parent
                    source: "assets/systems/" + modelData.shortName + ".png"
                    fillMode: Image.PreserveAspectFit
                    mipmap: true
                    asynchronous: true
                    visible: false
                }

                ColorOverlay {
                    anchors.fill: sysLogo
                    source: sysLogo
                    color: isSelected ? inkBlack : divColor
                    opacity: isSelected ? 0.75 : 0.89
                    Behavior on color   { ColorAnimation { duration: 150 } }
                    Behavior on opacity { NumberAnimation { duration: 150 } }
                }

                Rectangle {
                    anchors.centerIn: parent
                    width: vpx(7); height: vpx(7)
                    radius: width / 2
                    color: isSelected ? inkBlack : inkLight
                    visible: sysLogo.status === Image.Error
                             || sysLogo.status === Image.Null
                }
            }

            Text {
                anchors.left: logoSlot.right
                anchors.leftMargin: vpx(10)
                anchors.right: gameCount.left
                anchors.rightMargin: vpx(6)
                anchors.verticalCenter: parent.verticalCenter
                text: modelData.name
                font.family: global.fonts.sans
                font.pixelSize: isSelected ? vpx(17) : vpx(15)
                font.bold: isSelected
                color: isSelected ? inkBlack : inkMid
                elide: Text.ElideRight
                Behavior on font.pixelSize { NumberAnimation { duration: 100 } }
            }

            Text {
                id: gameCount
                anchors.right: parent.right
                anchors.rightMargin: vpx(14)
                anchors.verticalCenter: parent.verticalCenter
                text: modelData.games.count
                font.family: global.fonts.condensed
                font.pixelSize: vpx(11)
                color: isSelected ? inkLight : inkFaint
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
                onEntered: { if (!isSelected) del.opacity = 0.82 }
                onExited:  { del.opacity = 1.0 }
                onClicked: {
                    root.requestFocus()
                    sfx.playMove()
                    list.currentIndex = index
                    savedIndex = index
                    root.collectionChosen()
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
            y: (list.contentY / Math.max(1, list.contentHeight)) * parent.height
            width: parent.width
            height: Math.max(vpx(20),
                (list.height / Math.max(1, list.contentHeight)) * parent.height)
            color: inkFaint
            radius: 1
        }
    }
}
