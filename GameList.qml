import QtQuick 2.15
import SortFilterProxyModel 0.2
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

    property int activeFilter: 0

    readonly property int countAll:        collectionModel ? collectionModel.games.count : 0
    readonly property int countFavorites:  _countFavs()
    readonly property int countLastPlayed: _countLastPlayed()

    function _countFavs() {
        if (!collectionModel) return 0
            var n = 0
            for (var i = 0; i < collectionModel.games.count; i++) {
                var g = collectionModel.games.get(i)
                if (g && g.favorite) n++
            }
            return n
    }

    function _countLastPlayed() {
        if (!collectionModel) return 0
            var n = 0
            for (var i = 0; i < collectionModel.games.count; i++) {
                var g = collectionModel.games.get(i)
                if (g && g.lastPlayed && !isNaN(g.lastPlayed.getTime())) n++
            }
            return n
    }

    function nextFilter() {
        var order = _availableFilters()
        var cur   = order.indexOf(activeFilter)
        activeFilter = order[(cur + 1) % order.length]
        _resetListIndex()
    }

    function prevFilter() {
        var order = _availableFilters()
        var cur   = order.indexOf(activeFilter)
        activeFilter = order[(cur - 1 + order.length) % order.length]
        _resetListIndex()
    }

    function _availableFilters() {
        var a = [0]
        if (countFavorites  > 0) a.push(1)
            if (countLastPlayed > 0) a.push(2)
                return a
    }

    function _resetListIndex() {
        savedIndex = 0
        list.currentIndex = hasFocus ? 0 : -1
        if (filteredModel.count > 0) {
            currentGame = filteredModel.get(0)
        } else {
            currentGame = null
        }
    }

    SoundManager { id: sfx }
    Fonts { id: theFonts }

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
        activeFilter = 0
        savedIndex   = 0
        if (filteredModel.count > 0) {
            currentGame = filteredModel.get(0)
        } else {
            currentGame = (collectionModel && collectionModel.games.count > 0)
            ? collectionModel.games.get(0) : null
        }
    }

    SortFilterProxyModel {
        id: filteredModel
        sourceModel: collectionModel ? collectionModel.games : null

        filters: [
            ExpressionFilter {
                enabled: root.activeFilter === 1
                expression: model.favorite === true
            },
            ExpressionFilter {
                enabled: root.activeFilter === 2
                expression: {
                    var lp = model.lastPlayed
                    return lp && !isNaN(lp.getTime())
                }
            }
        ]

        sorters: ExpressionSorter {
            enabled: root.activeFilter === 2
            expression: {
                var la = modelLeft.lastPlayed  ? modelLeft.lastPlayed.getTime()  : 0
                var lb = modelRight.lastPlayed ? modelRight.lastPlayed.getTime() : 0
                return la > lb
            }
        }
    }

    Rectangle { anchors.fill: parent; color: bgColor }

    Item {
        id: panelHeader
        x: 0; y: 0
        width: parent.width
        height: vpx(52)

        Row {
            anchors.left:           parent.left
            anchors.leftMargin:     vpx(12)
            anchors.verticalCenter: parent.verticalCenter
            spacing: vpx(4)

            Item {
                id: tabAll
                width:  labelAll.width + countAll_txt.width + vpx(18)
                height: vpx(28)

                readonly property bool active: root.activeFilter === 0

                Rectangle {
                    anchors.fill: parent
                    radius: vpx(4)
                    color:   tabAll.active ? root.inkBlack   : "transparent"
                    border.color: tabAll.active ? "transparent" : root.divColor
                    border.width: 1
                    Behavior on color { ColorAnimation { duration: 130 } }
                }

                Row {
                    anchors.centerIn: parent
                    spacing: vpx(5)

                    Text {
                        id: labelAll
                        text: "ALL"
                        font.family: theFonts.publicSans
                        font.pixelSize: vpx(10)
                        font.letterSpacing: vpx(2)
                        font.bold: tabAll.active
                        color: tabAll.active ? root.bgColor : root.inkFaint
                        anchors.verticalCenter: parent.verticalCenter
                        Behavior on color { ColorAnimation { duration: 130 } }
                    }
                    Text {
                        id: countAll_txt
                        text: root.countAll
                        font.family: theFonts.publicSans
                        font.pixelSize: vpx(10)
                        color: tabAll.active ? Qt.rgba(root.bgColor.r, root.bgColor.g, root.bgColor.b, 0.6)
                        : root.inkFaint
                        anchors.verticalCenter: parent.verticalCenter
                        Behavior on color { ColorAnimation { duration: 130 } }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        root.requestFocus()
                        if (root.activeFilter !== 0) {
                            sfx.playMove()
                            root.activeFilter = 0
                            root._resetListIndex()
                        }
                    }
                }
            }

            Item {
                id: tabFav
                width:  labelFav.width + countFav_txt.width + vpx(18)
                height: vpx(28)
                visible: root.countFavorites > 0

                readonly property bool active: root.activeFilter === 1

                Rectangle {
                    anchors.fill: parent
                    radius: vpx(4)
                    color:   tabFav.active ? root.inkBlack   : "transparent"
                    border.color: tabFav.active ? "transparent" : root.divColor
                    border.width: 1
                    Behavior on color { ColorAnimation { duration: 130 } }
                }

                Row {
                    anchors.centerIn: parent
                    spacing: vpx(5)

                    Text {
                        id: labelFav
                        text: "♥  FAV"
                        font.family: theFonts.publicSans
                        font.pixelSize: vpx(10)
                        font.letterSpacing: vpx(2)
                        font.bold: tabFav.active
                        color: tabFav.active ? root.bgColor : root.inkFaint
                        anchors.verticalCenter: parent.verticalCenter
                        Behavior on color { ColorAnimation { duration: 130 } }
                    }
                    Text {
                        id: countFav_txt
                        text: root.countFavorites
                        font.family: theFonts.publicSans
                        font.pixelSize: vpx(10)
                        color: tabFav.active ? Qt.rgba(root.bgColor.r, root.bgColor.g, root.bgColor.b, 0.6)
                        : root.inkFaint
                        anchors.verticalCenter: parent.verticalCenter
                        Behavior on color { ColorAnimation { duration: 130 } }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        root.requestFocus()
                        if (root.activeFilter !== 1) {
                            sfx.playMove()
                            root.activeFilter = 1
                            root._resetListIndex()
                        }
                    }
                }
            }

            Item {
                id: tabLast
                width:  labelLast.width + countLast_txt.width + vpx(18)
                height: vpx(28)
                visible: root.countLastPlayed > 0

                readonly property bool active: root.activeFilter === 2

                Rectangle {
                    anchors.fill: parent
                    radius: vpx(4)
                    color:   tabLast.active ? root.inkBlack   : "transparent"
                    border.color: tabLast.active ? "transparent" : root.divColor
                    border.width: 1
                    Behavior on color { ColorAnimation { duration: 130 } }
                }

                Row {
                    anchors.centerIn: parent
                    spacing: vpx(5)

                    Text {
                        id: labelLast
                        text: "▶  PLAYED"
                        font.family: theFonts.publicSans
                        font.pixelSize: vpx(10)
                        font.letterSpacing: vpx(2)
                        font.bold: tabLast.active
                        color: tabLast.active ? root.bgColor : root.inkFaint
                        anchors.verticalCenter: parent.verticalCenter
                        Behavior on color { ColorAnimation { duration: 130 } }
                    }
                    Text {
                        id: countLast_txt
                        text: root.countLastPlayed
                        font.family: theFonts.publicSans
                        font.pixelSize: vpx(10)
                        color: tabLast.active ? Qt.rgba(root.bgColor.r, root.bgColor.g, root.bgColor.b, 0.6)
                        : root.inkFaint
                        anchors.verticalCenter: parent.verticalCenter
                        Behavior on color { ColorAnimation { duration: 130 } }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        root.requestFocus()
                        if (root.activeFilter !== 2) {
                            sfx.playMove()
                            root.activeFilter = 2
                            root._resetListIndex()
                        }
                    }
                }
            }
        }

        Row {
            anchors.right:          parent.right
            anchors.rightMargin:    vpx(12)
            anchors.verticalCenter: parent.verticalCenter
            spacing: vpx(4)
            visible: root.countFavorites > 0 || root.countLastPlayed > 0
            opacity: root.hasFocus ? 1.0 : 0.45
            Behavior on opacity { NumberAnimation { duration: 180 } }

            Rectangle {
                width:  lbLabel.width + vpx(14)
                height: vpx(22)
                radius: vpx(5)
                color:        "transparent"
                border.color: root.divColor
                border.width: 1

                Text {
                    id: lbLabel
                    anchors.centerIn: parent
                    text: "LB"
                    font.family:       theFonts.publicSans
                    font.pixelSize:    vpx(9)
                    font.letterSpacing: vpx(1.5)
                    font.bold:         true
                    color:             root.inkFaint
                }
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: "●"
                font.pixelSize: vpx(6)
                color:          root.inkFaint
                opacity:        0.7
            }

            Rectangle {
                width:  rbLabel.width + vpx(14)
                height: vpx(22)
                radius: vpx(5)
                color:        "transparent"
                border.color: root.divColor
                border.width: 1

                Text {
                    id: rbLabel
                    anchors.centerIn: parent
                    text: "RB"
                    font.family:       theFonts.publicSans
                    font.pixelSize:    vpx(9)
                    font.letterSpacing: vpx(1.5)
                    font.bold:         true
                    color:             root.inkFaint
                }
            }
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
        model: filteredModel
        clip: true
        highlightMoveDuration: 100
        keyNavigationEnabled: false
        focus: false

        onModelChanged: {
            if (!root.hasFocus) currentIndex = -1
        }

        onCurrentIndexChanged: {
            if (currentIndex >= 0) {
                var g = filteredModel.get(currentIndex)
                if (g) {
                    currentGame = g
                    savedIndex  = currentIndex
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
                    font.family: theFonts.publicSans
                    font.pixelSize: isSelected ? vpx(16) : vpx(14)
                    font.bold: isSelected
                    color: isSelected ? inkBlack : inkMid
                    elide: Text.ElideRight
                    Behavior on font.pixelSize { NumberAnimation { duration: 100 } }
                }

                Text {
                    width: parent.width
                    text: Util.buildMeta(modelData)
                    font.family: theFonts.lora
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
        text: {
            if (!collectionModel) return "No games in this collection"
                if (root.activeFilter === 1) return "No favorite games"
                    if (root.activeFilter === 2) return "No recently played games"
                        return "No games in this collection"
        }
        font.family: theFonts.publicSans
        font.pixelSize: vpx(14)
        font.letterSpacing: vpx(2)
        color: inkFaint
        visible: filteredModel.count === 0
    }
}
