import QtQuick 2.15
import QtGraphicalEffects 1.15
import "util.js" as Util

Item {
    id: root
    width: parent.width
    height: parent.height

    SoundManager { id: sfx }

    Fonts { id: theFonts }

    property bool darkMode: false
    property bool nightLight: false

    Component.onCompleted: {
        if (api.memory.has("paperTheme.darkMode"))
            darkMode = api.memory.get("paperTheme.darkMode") === true
        if (api.memory.has("paperTheme.nightLight"))
            nightLight = api.memory.get("paperTheme.nightLight") === true
    }

    onDarkModeChanged: {
        api.memory.set("paperTheme.darkMode", darkMode)
    }

    onNightLightChanged: {
        api.memory.set("paperTheme.nightLight", nightLight)
    }

    property color bgColor:  darkMode ? "#1A1A1A" : "#EDE9DF"
    property color panelBg:  darkMode ? "#252525" : "#E2DDD0"
    property color inkBlack: darkMode ? "#EDE9DF" : "#1A1A1A"
    property color inkDark:  darkMode ? "#E2DDD0" : "#252525"
    property color inkMid:   darkMode ? "#CCCCCC" : "#333333"
    property color inkLight: darkMode ? "#AAAAAA" : "#555555"
    property color inkFaint: darkMode ? "#888888" : "#7A7A7A"
    property color divColor: darkMode ? "#504C44" : "#8A8070"

    Behavior on bgColor  { ColorAnimation { duration: 220 } }
    Behavior on panelBg  { ColorAnimation { duration: 220 } }
    Behavior on inkBlack { ColorAnimation { duration: 220 } }
    Behavior on inkDark  { ColorAnimation { duration: 220 } }
    Behavior on inkMid   { ColorAnimation { duration: 220 } }
    Behavior on inkLight { ColorAnimation { duration: 220 } }
    Behavior on inkFaint { ColorAnimation { duration: 220 } }
    Behavior on divColor { ColorAnimation { duration: 220 } }

    property string focusPanel: "collections"
    property bool galleryOpen: false

    function openGallery() {
        if (!gamePanel.currentGame) return
        galleryOpen = true
        focusPanel  = "gallery"
    }
    function closeGallery() {
        galleryOpen = false
        focusPanel  = "games"
    }

    property bool   showExitMenu:   false
    property int    exitMenuIndex:  0

    Rectangle { anchors.fill: parent; color: bgColor }

    ShaderEffect {
        anchors.fill: parent
        opacity: 0.04
        fragmentShader: "
        uniform float qt_Opacity;
        varying highp vec2 qt_TexCoord0;
        highp float rand(highp vec2 co){
        return fract(sin(dot(co,vec2(12.9898,78.233)))*43758.5453);
    }
    void main(){
    highp float g = rand(qt_TexCoord0 * 800.0);
    gl_FragColor = vec4(vec3(g), qt_Opacity);
    }
    "
    }

    Rectangle {
        id: nightLightOverlay
        anchors.fill: parent
        color: "#623405"
        opacity: nightLight ? 0.35 : 0.0
        z: 998
        visible: opacity > 0
        Behavior on opacity { NumberAnimation { duration: 400; easing.type: Easing.InOutQuad } }
    }

    Rectangle {
        id: nightLightDim
        anchors.fill: parent
        color: "#000000"
        opacity: nightLight ? 0.55 : 0.0
        z: 999
        visible: opacity > 0
        Behavior on opacity { NumberAnimation { duration: 400; easing.type: Easing.InOutQuad } }
    }

    Item {
        anchors.fill: parent
        transformOrigin: Item.Center

        scale: showExitMenu ? 0.75 : 1.0
        Behavior on scale {
            NumberAnimation { duration: 280; easing.type: Easing.OutCubic }
        }

        Item {
            id: topBar
            x: 0; y: 0
            width: parent.width
            height: vpx(56)

            Rectangle { anchors.fill: parent; color: inkBlack }

            Text {
                id: titleText
                anchors.left: parent.left
                anchors.leftMargin: vpx(32)
                anchors.verticalCenter: parent.verticalCenter
                text: "PEGASUS PAPER"
                font.family: theFonts.publicSans
                font.pixelSize: vpx(18)
                font.letterSpacing: vpx(6)
                color: bgColor
            }

            Item {
                id: themeToggle
                anchors.left: titleText.right
                anchors.leftMargin: vpx(14)
                anchors.verticalCenter: parent.verticalCenter
                width: vpx(48)
                height: vpx(48)

                Image {
                    id: toggleIcon
                    anchors.fill: parent
                    source: darkMode
                    ? "assets/icons/toggle-on.svg"
                    : "assets/icons/toggle-off.svg"
                    fillMode: Image.PreserveAspectFit
                    mipmap: true
                    smooth: true
                    visible: false
                }

                ColorOverlay {
                    anchors.fill: toggleIcon
                    source: toggleIcon
                    color: bgColor
                    opacity: toggleMouse.containsMouse ? 1.0 : 0.75
                    Behavior on color   { ColorAnimation { duration: 150 } }
                    Behavior on opacity { NumberAnimation { duration: 150 } }
                }

                MouseArea {
                    id: toggleMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        sfx.playMove()
                        root.darkMode = !root.darkMode
                    }
                }
            }

            Text {
                anchors.centerIn: parent
                text: collectionPanel.currentCollection
                ? collectionPanel.currentCollection.name.toUpperCase() : ""
                font.family: theFonts.publicSans
                font.pixelSize: vpx(13)
                font.letterSpacing: vpx(5)
                color: inkFaint
            }

            Item {
                id: nightLightToggle
                anchors.left: themeToggle.right
                anchors.leftMargin: vpx(4)
                anchors.verticalCenter: parent.verticalCenter
                width: vpx(36)
                height: vpx(36)

                Image {
                    id: nightLightIcon
                    anchors.fill: parent
                    source: nightLight
                           ? "assets/icons/on.svg"
                           : "assets/icons/off.svg"
                    fillMode: Image.PreserveAspectFit
                    mipmap: true
                    smooth: true
                    visible: false
                }

                ColorOverlay {
                    anchors.fill: nightLightIcon
                    source: nightLightIcon
                    color: nightLight ? "#F5C97A" : bgColor
                    opacity: nightLightMouse.containsMouse ? 1.0 : (nightLight ? 0.9 : 0.6)
                    Behavior on color   { ColorAnimation { duration: 200 } }
                    Behavior on opacity { NumberAnimation { duration: 150 } }
                }

                MouseArea {
                    id: nightLightMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        sfx.playMove()
                        root.nightLight = !root.nightLight
                    }
                }
            }

            Text {
                anchors.right: parent.right
                anchors.rightMargin: vpx(32)
                anchors.verticalCenter: parent.verticalCenter
                font.family: theFonts.publicSans
                font.pixelSize: vpx(15)
                font.letterSpacing: vpx(3)
                color: inkFaint
                function pad(n) { return n < 10 ? "0" + n : "" + n }
                function tick() {
                    var d = new Date()
                    text = pad(d.getHours()) + ":" + pad(d.getMinutes())
                }
                Component.onCompleted: tick()
            }
            Timer { interval: 10000; repeat: true; running: true; onTriggered: clockText.tick() }
        }

        CollectionList {
            id: collectionPanel
            x: 0
            y: topBar.height
            width: vpx(252)
            height: parent.height - topBar.height

            bgColor:  root.panelBg
            inkBlack: root.inkBlack
            inkDark:  root.inkDark
            inkMid:   root.inkMid
            inkLight: root.inkLight
            inkFaint: root.inkFaint
            divColor: root.divColor
            hasFocus: root.focusPanel === "collections"

            onRequestFocus:     root.focusPanel = "collections"
            onCollectionChosen: root.focusPanel = "games"
        }

        Rectangle {
            x: collectionPanel.width; y: topBar.height
            width: 1; height: parent.height - topBar.height
            color: divColor
        }

        GameList {
            id: gamePanel
            x: collectionPanel.width + 1
            y: topBar.height
            width: vpx(424)
            height: parent.height - topBar.height

            collectionModel: collectionPanel.currentCollection
            bgColor:  root.bgColor
            inkBlack: root.inkBlack
            inkDark:  root.inkDark
            inkMid:   root.inkMid
            inkLight: root.inkLight
            inkFaint: root.inkFaint
            divColor: root.divColor
            hasFocus: root.focusPanel === "games"

            onRequestFocus: root.focusPanel = "games"
            onRequestBack:  root.focusPanel = "collections"
            onToggleTheme:  root.darkMode = !root.darkMode
        }

        Rectangle {
            x: collectionPanel.width + 1 + gamePanel.width
            y: topBar.height
            width: 1; height: parent.height - topBar.height
            color: divColor
        }

        GameDetail {
            id: detailPanel
            x: collectionPanel.width + 1 + gamePanel.width + 1
            y: topBar.height
            width: parent.width - collectionPanel.width - gamePanel.width - 2
            height: parent.height - topBar.height

            game:     gamePanel.currentGame
            bgColor:  root.bgColor
            inkBlack: root.inkBlack
            inkDark:  root.inkDark
            inkMid:   root.inkMid
            inkLight: root.inkLight
            inkFaint: root.inkFaint
            divColor: root.divColor

            onRequestGallery: root.openGallery()
        }
    }

    Loader {
        id: galleryLoader
        anchors.fill: parent
        active: root.galleryOpen
        source: root.galleryOpen ? "MediaGallery.qml" : ""

        onLoaded: {
            item.game     = Qt.binding(function() { return gamePanel.currentGame })
            item.bgColor  = Qt.binding(function() { return root.bgColor  })
            item.inkBlack = Qt.binding(function() { return root.inkBlack })
            item.inkFaint = Qt.binding(function() { return root.inkFaint })
            item.divColor = Qt.binding(function() { return root.divColor })
            item.closed.connect(root.closeGallery)
        }
    }

    Rectangle {
        id: dimOverlay
        anchors.fill: parent
        color: "#000000"
        opacity: showExitMenu ? 0.45 : 0.0
        visible: opacity > 0
        Behavior on opacity { NumberAnimation { duration: 260; easing.type: Easing.OutCubic } }
    }

    Item {
        id: exitBar
        width: parent.width
        height: vpx(88)
        y: showExitMenu ? parent.height - height : parent.height
        Behavior on y { NumberAnimation { duration: 280; easing.type: Easing.OutCubic } }

        Rectangle {
            anchors.fill: parent
            color: darkMode ? "#1E1E1E" : "#F5F1E8"
            Rectangle {
                width: parent.width; height: 1
                color: divColor
            }
        }

        Row {
            anchors.centerIn: parent
            spacing: vpx(24)

            Repeater {
                model: [
                    { label: "CANCEL", icon: "✕" },
                    { label: "QUIT",   icon: "⏻" }
                ]

                delegate: Item {
                    width:  vpx(160)
                    height: vpx(60)

                    readonly property bool isSelected: exitMenuIndex === index

                    Rectangle {
                        anchors.fill: parent
                        radius: vpx(6)
                        color: isSelected
                        ? (darkMode ? "#3A3A3A" : "#D8D2C4")
                        : "transparent"
                        border.color: isSelected ? divColor : "transparent"
                        border.width: 1
                        Behavior on color { ColorAnimation { duration: 150 } }
                    }

                    Row {
                        anchors.centerIn: parent
                        spacing: vpx(10)
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: modelData.icon
                            font.pixelSize: vpx(18)
                            color: isSelected ? inkBlack : inkFaint
                            Behavior on color { ColorAnimation { duration: 150 } }
                        }
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: modelData.label
                            font.family: theFonts.publicSans
                            font.pixelSize: vpx(14)
                            font.letterSpacing: vpx(3)
                            color: isSelected ? inkBlack : inkFaint
                            Behavior on color { ColorAnimation { duration: 150 } }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: exitMenuIndex = index
                        onClicked: {
                            if (index === 0) { sfx.playCancel(); root.closeExitMenu() }
                            else             { sfx.playCancel(); root.closeExitMenu(); Qt.quit() }
                        }
                    }
                }
            }

            Rectangle {
                width: 1; height: vpx(44)
                anchors.verticalCenter: parent.verticalCenter
                color: divColor
            }

            Item {
                width:  vpx(190)
                height: vpx(60)

                Rectangle {
                    anchors.fill: parent
                    radius: vpx(6)
                    color: "transparent"
                    border.color: divColor
                    border.width: 1
                    opacity: 0.5
                }

                Column {
                    anchors.centerIn: parent
                    spacing: vpx(3)

                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: vpx(8)
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: "☰"
                            font.pixelSize: vpx(16)
                            color: inkFaint
                        }
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: "PEGASUS MENU"
                            font.family: theFonts.publicSans
                            font.pixelSize: vpx(14)
                            font.letterSpacing: vpx(3)
                            color: inkFaint
                        }
                    }
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "[ B / Cancel ]"
                        font.family: theFonts.publicSans
                        font.pixelSize: vpx(10)
                        font.letterSpacing: vpx(2)
                        color: inkFaint
                        opacity: 0.7
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: exitMenuIndex = 2
                }
            }
        }
    }

    function openExitMenu() {
        exitMenuIndex = 0
        showExitMenu  = true
    }

    function closeExitMenu() {
        showExitMenu = false
    }

    function activateExitOption(idx, event) {
        switch (idx) {
            case 0:
                sfx.playCancel()
                closeExitMenu()
                event.accepted = true
                break
            case 1:
                sfx.playCancel()
                closeExitMenu()
                event.accepted = true
                Qt.quit()
                break
        }
    }

    Keys.onPressed: {

        if (event.key === Qt.Key_N) {
            event.accepted = true
            sfx.playMove()
            root.nightLight = !root.nightLight
            return
        }

        if (focusPanel === "gallery") {
            if (api.keys.isCancel(event) || event.key === Qt.Key_Escape) {
                event.accepted = true
                root.closeGallery()
                return
            }
            event.accepted = true
            return
        }

        if (showExitMenu) {
            if (event.key === Qt.Key_Left) {
                event.accepted = true
                sfx.playMove()
                exitMenuIndex = (exitMenuIndex - 1 + 2) % 2
                return
            }
            if (event.key === Qt.Key_Right) {
                event.accepted = true
                sfx.playMove()
                exitMenuIndex = (exitMenuIndex + 1) % 2
                return
            }
            if (api.keys.isAccept(event)) {
                activateExitOption(exitMenuIndex, event)
                return
            }
            if (api.keys.isCancel(event)) {
                closeExitMenu()
                event.accepted = false
                return
            }
            event.accepted = true
            return
        }

        if (focusPanel === "collections") {

            if (event.key === Qt.Key_G) {
                event.accepted = true
                sfx.playMove()
                root.openGallery()
                return
            }

            if (event.key === Qt.Key_Up) {
                event.accepted = true
                sfx.playMove()
                collectionPanel.moveUp()
                return
            }

            if (event.key === Qt.Key_Down) {
                event.accepted = true
                sfx.playMove()
                collectionPanel.moveDown()
                return
            }

            if (event.key === Qt.Key_Right || api.keys.isAccept(event)) {
                event.accepted = true
                sfx.playMove()
                focusPanel = "games"
                return
            }

            if (api.keys.isCancel(event)) {
                event.accepted = true
                sfx.playCancel()
                openExitMenu()
                return
            }

            if (api.keys.isFilters(event)) {
                event.accepted = true
                sfx.playMove()
                root.darkMode = !root.darkMode
                return
            }
        }

        else if (focusPanel === "games") {

            if (event.key === Qt.Key_G) {
                event.accepted = true
                sfx.playMove()
                root.openGallery()
                return
            }

            if (event.key === Qt.Key_Up) {
                event.accepted = true
                sfx.playMove()
                gamePanel.moveUp()
                return
            }

            if (event.key === Qt.Key_Down) {
                event.accepted = true
                sfx.playMove()
                gamePanel.moveDown()
                return
            }

            if (event.key === Qt.Key_Left || api.keys.isCancel(event)) {
                event.accepted = true
                sfx.playMove()
                focusPanel = "collections"
                return
            }

            if (api.keys.isAccept(event)) {
                event.accepted = true
                sfx.playMove()
                gamePanel.launchCurrent()
                return
            }

            if (api.keys.isDetails(event)) {
                event.accepted = true
                sfx.playFavorite()
                gamePanel.toggleFavorite()
                return
            }

            if (api.keys.isFilters(event)) {
                event.accepted = true
                sfx.playMove()
                root.darkMode = !root.darkMode
                return
            }

            if (api.keys.isNextPage(event)) {
                event.accepted = true
                sfx.playMove()
                gamePanel.nextFilter()
                return
            }

            if (api.keys.isPrevPage(event)) {
                event.accepted = true
                sfx.playMove()
                gamePanel.prevFilter()
                return
            }
        }
    }

    focus: true
}
