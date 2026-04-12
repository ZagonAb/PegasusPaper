import QtQuick 2.15
import QtGraphicalEffects 1.15

Item {
    id: root

    property var game: null
    property color bgColor:"#F5F0E8"
    property color inkBlack: "#1A1A1A"
    property color inkFaint: "#AAAAAA"
    property color divColor: "#DDDDDD"

    property bool grayscaleActive: true

    signal closed()

    SoundManager { id: sfx }

    Component.onCompleted: {
        if (api.memory.has("paperTheme.galleryGrayscale")) {
            root.grayscaleActive = api.memory.get("paperTheme.galleryGrayscale") === true
        }
        root.forceActiveFocus()
    }

    onGrayscaleActiveChanged: {
        api.memory.set("paperTheme.galleryGrayscale", root.grayscaleActive)
    }

    function isVideoUrl(u) {
        if (!u) return false
            var s = u.toString().toLowerCase()
            return s.endsWith(".mp4")  || s.endsWith(".mkv") ||
            s.endsWith(".avi") || s.endsWith(".webm") ||
            s.endsWith(".mov") || s.endsWith(".flv")  ||
            s.endsWith(".m4v")
    }

    function buildMediaList(g) {
        if (!g) return []
            var a  = g.assets
            var seen = {}
            var urls = []
            function add(u) {
                if (u && u !== "" && !seen[u]) { seen[u] = true; urls.push(u) }
            }
            function addList(lst) {
                if (!lst) return
                    for (var i = 0; i < lst.length; i++) add(lst[i])
            }

            add(a.screenshot);  add(a.titlescreen); add(a.background)
            add(a.banner); add(a.poster); add(a.boxFront)
            add(a.boxBack); add(a.boxFull); add(a.cartridge)
            add(a.logo);  add(a.tile); add(a.steam)
            add(a.marquee); add(a.bezel); add(a.panel)
            add(a.cabinetLeft); add(a.cabinetRight)
            addList(a.screenshotList); addList(a.titlescreenList)
            addList(a.backgroundList); addList(a.bannerList); addList(a.posterList)
            add(a.video)
            addList(a.videoList)
            return urls
    }

    property var  mediaUrls:  buildMediaList(game)
    property int  currentIdx: 0
    property bool zoomActive: false

    readonly property bool currentIsVideo:
    mediaUrls.length > 0 && isVideoUrl(mediaUrls[currentIdx])

    function goPrev() { if (mediaUrls.length > 0) currentIdx = (currentIdx - 1 + mediaUrls.length) % mediaUrls.length }
    function goNext() { if (mediaUrls.length > 0) currentIdx = (currentIdx + 1) % mediaUrls.length }
    function openZoom() { if (!currentIsVideo) zoomActive = true  }
    function closeZoom() { zoomActive = false }
    function closeGallery() { root.closed() }

    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.72)
        MouseArea {
            anchors.fill: parent
            onClicked: {
                if (!zoomActive) closeGallery()
            }
        }
    }

    Rectangle {
        id: card
        anchors.centerIn: parent
        width: Math.min(parent.width  * 0.96, vpx(1100))
        height: Math.min(parent.height * 0.92, vpx(700))
        color: bgColor
        radius: vpx(6)

        MouseArea { anchors.fill: parent; onClicked: {} }

        Item {
            id: header
            anchors { top: parent.top; left: parent.left; right: parent.right }
            height: vpx(40)

            Text {
                anchors.centerIn: parent
                text: mediaUrls.length > 0 ? (currentIdx + 1) + " / " + mediaUrls.length : "Sin medios"
                font.pixelSize: vpx(12)
                font.letterSpacing: vpx(3)
                color: inkFaint
            }

            Rectangle {
                anchors.left: parent.left
                anchors.leftMargin: vpx(10)
                anchors.verticalCenter: parent.verticalCenter
                visible: root.currentIsVideo
                width: vpx(72)
                height: vpx(25)
                radius: vpx(3)
                color: Qt.rgba(0, 0, 0, 0.18)
                Text {
                    anchors.centerIn: parent
                    text: "▶ VIDEO"
                    font.pixelSize: vpx(9)
                    font.letterSpacing: vpx(2)
                    color: inkFaint
                }
            }

            Rectangle {
                anchors.left: parent.left
                anchors.leftMargin: root.currentIsVideo ? vpx(92) : vpx(10)
                anchors.verticalCenter: parent.verticalCenter
                width: vpx(28)
                height: vpx(28)
                radius: vpx(4)
                color: grayscaleToggleHover.containsMouse ? inkBlack : "transparent"
                border.color: inkFaint
                border.width: 1
                Behavior on color { ColorAnimation { duration: 100 } }

                Image {
                    id: grayscaleIconHeader
                    anchors.fill: parent
                    source: root.grayscaleActive
                    ? "assets/icons/color-off.svg"
                    : "assets/icons/color-on.svg"
                    fillMode: Image.PreserveAspectFit
                    mipmap: true
                    smooth: true
                    visible: false
                }

                ColorOverlay {
                    anchors.fill: grayscaleIconHeader
                    source: grayscaleIconHeader
                    color: grayscaleToggleHover.containsMouse ? bgColor : inkFaint
                    Behavior on color { ColorAnimation { duration: 150 } }
                }

                MouseArea {
                    id: grayscaleToggleHover
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        sfx.playMove()
                        root.grayscaleActive = !root.grayscaleActive
                    }
                }
            }

            Rectangle {
                anchors.right: parent.right
                anchors.rightMargin: vpx(10)
                anchors.verticalCenter: parent.verticalCenter
                width: vpx(28)
                height: vpx(28)
                radius: vpx(4)
                color: closeHover.containsMouse ? inkBlack : "transparent"
                border.color: inkFaint
                border.width: 1
                Behavior on color { ColorAnimation { duration: 100 } }
                Text {
                    anchors.centerIn: parent
                    text: "✕"
                    font.pixelSize: vpx(12)
                    color: closeHover.containsMouse ? bgColor : inkFaint
                    Behavior on color { ColorAnimation { duration: 100 } }
                }
                MouseArea {
                    id: closeHover
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        sfx.playMove()
                        closeGallery()
                    }
                }
            }

            Rectangle {
                anchors.bottom: parent.bottom
                width: parent.width
                height: 1
                color: divColor
            }
        }

        Item {
            id: viewZone
            anchors {
                top: header.bottom
                left: parent.left
                right: parent.right
                bottom: thumbStrip.top
            }
            clip: true

            Text {
                anchors.centerIn: parent
                visible: mediaUrls.length === 0
                text: "This game has no media."
                font.pixelSize: vpx(14)
                font.letterSpacing: vpx(2)
                color: inkFaint
            }

            GrayscaleImage {
                id: mainImage
                anchors.fill: parent
                anchors.margins: vpx(12)
                source: mediaUrls.length > 0 ? mediaUrls[currentIdx] : ""
                fillMode: Image.PreserveAspectFit
                grayscaleEnabled: root.grayscaleActive
            }

            Rectangle {
                anchors.centerIn: parent
                width: vpx(6)
                height: vpx(6)
                radius: vpx(3)
                color: inkFaint
                visible: mediaUrls.length > 0 && mainImage.paintedWidth === 0
                SequentialAnimation on opacity {
                    loops: Animation.Infinite
                    NumberAnimation { to: 0.1; duration: 500 }
                    NumberAnimation { to: 1.0; duration: 500 }
                }
            }

            MouseArea {
                anchors.fill: parent
                anchors.leftMargin: vpx(44)
                anchors.rightMargin: vpx(44)
                property real startX: 0
                property bool dragging: false
                onPressed: {
                    startX = mouse.x
                    dragging = false
                }
                onPositionChanged: {
                    if (Math.abs(mouse.x - startX) > vpx(10)) dragging = true
                }
                onReleased: {
                    if (!dragging) return
                        if (mouse.x - startX < -vpx(30)) goNext()
                            else if (mouse.x - startX > vpx(30)) goPrev()
                }
                onDoubleClicked: {
                    if (mediaUrls.length > 0 && !root.currentIsVideo) {
                        sfx.playMove()
                        openZoom()
                    }
                }
                cursorShape: Qt.OpenHandCursor
            }

            Rectangle {
                anchors.left: parent.left
                anchors.leftMargin: vpx(6)
                anchors.verticalCenter: parent.verticalCenter
                width: vpx(34)
                height: vpx(54)
                radius: vpx(4)
                color: aL.containsMouse ? inkBlack : Qt.rgba(0,0,0,0.12)
                visible: mediaUrls.length > 1
                Behavior on color { ColorAnimation { duration: 100 } }
                Text {
                    anchors.centerIn: parent
                    text: "‹"
                    font.pixelSize: vpx(26)
                    color: aL.containsMouse ? bgColor : inkFaint
                    Behavior on color { ColorAnimation { duration: 100 } }
                }
                MouseArea {
                    id: aL
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        sfx.playMove()
                        goPrev()
                    }
                }
            }

            Rectangle {
                anchors.right: parent.right
                anchors.rightMargin: vpx(6)
                anchors.verticalCenter: parent.verticalCenter
                width: vpx(34)
                height: vpx(54)
                radius: vpx(4)
                color: aR.containsMouse ? inkBlack : Qt.rgba(0,0,0,0.12)
                visible: mediaUrls.length > 1
                Behavior on color { ColorAnimation { duration: 100 } }
                Text {
                    anchors.centerIn: parent
                    text: "›"
                    font.pixelSize: vpx(26)
                    color: aR.containsMouse ? bgColor : inkFaint
                    Behavior on color { ColorAnimation { duration: 100 } }
                }
                MouseArea {
                    id: aR
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        sfx.playMove()
                        goNext()
                    }
                }
            }
        }

        Item {
            id: thumbStrip
            anchors {
                bottom: parent.bottom
                left: parent.left
                right: parent.right
            }
            height: vpx(78)
            clip: true

            Rectangle {
                anchors.top: parent.top
                width: parent.width
                height: 1
                color: divColor
            }

            Rectangle {
                id: thumbGrayscaleToggle
                anchors.right: parent.right
                anchors.rightMargin: vpx(6)
                anchors.verticalCenter: parent.verticalCenter
                width: vpx(54)
                height: vpx(54)
                radius: vpx(4)
                color: thumbToggleHover.containsMouse ? inkBlack : Qt.rgba(0,0,0,0.12)
                Behavior on color { ColorAnimation { duration: 100 } }

                Image {
                    id: thumbGrayscaleIcon
                    anchors.fill: parent
                    source: root.grayscaleActive
                    ? "assets/icons/color-off.svg"
                    : "assets/icons/color-on.svg"
                    fillMode: Image.PreserveAspectFit
                    mipmap: true
                    smooth: true
                    visible: false
                }

                ColorOverlay {
                    anchors.fill: thumbGrayscaleIcon
                    source: thumbGrayscaleIcon
                    color: thumbToggleHover.containsMouse ? bgColor : inkFaint
                    Behavior on color { ColorAnimation { duration: 150 } }
                }

                MouseArea {
                    id: thumbToggleHover
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        sfx.playMove()
                        root.grayscaleActive = !root.grayscaleActive
                    }
                }
            }

            ListView {
                id: thumbList
                anchors.fill: parent
                anchors.rightMargin: vpx(52)
                anchors.margins: vpx(6)
                orientation: ListView.Horizontal
                spacing: vpx(6)
                model: mediaUrls.length
                currentIndex: root.currentIdx
                highlightMoveDuration: 200
                clip: true
                onCurrentIndexChanged: positionViewAtIndex(currentIndex, ListView.Center)

                delegate: Rectangle {
                    width: vpx(80)
                    height: vpx(54)
                    radius: vpx(3)
                    color: "transparent"
                    clip: true
                    border.color: index === root.currentIdx ? inkBlack : "transparent"
                    border.width: 2

                    GrayscaleImage {
                        anchors.fill: parent
                        anchors.margins: vpx(2)
                        source: !root.isVideoUrl(mediaUrls[index]) ? mediaUrls[index] : ""
                        fillMode: Image.PreserveAspectFit
                        opacity: index === root.currentIdx ? 1.0 : 0.45
                        grayscaleEnabled: root.grayscaleActive
                        Behavior on opacity { NumberAnimation { duration: 120 } }
                        z: -1
                    }

                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: vpx(2)
                        visible: root.isVideoUrl(mediaUrls[index])
                        color: index === root.currentIdx
                        ? Qt.rgba(0, 0, 0, 0.55)
                        : Qt.rgba(0, 0, 0, 0.28)
                        radius: vpx(2)
                        Behavior on color { ColorAnimation { duration: 120 } }

                        Text {
                            anchors.centerIn: parent
                            text: "▶"
                            font.pixelSize: vpx(18)
                            color: index === root.currentIdx
                            ? Qt.rgba(1, 1, 1, 0.90)
                            : Qt.rgba(1, 1, 1, 0.40)
                            Behavior on color { ColorAnimation { duration: 120 } }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            sfx.playMove()
                            root.currentIdx = index
                        }
                    }
                }
            }
        }
    }

    Rectangle {
        id: zoomOverlay
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.92)
        opacity: zoomActive ? 1.0 : 0.0
        visible: opacity > 0
        Behavior on opacity { NumberAnimation { duration: 200 } }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                sfx.playMove()
                closeZoom()
            }
        }

        GrayscaleImage {
            anchors.fill: parent
            anchors.margins: vpx(32)
            source: mediaUrls.length > 0 ? mediaUrls[currentIdx] : ""
            fillMode: Image.PreserveAspectFit
            grayscaleEnabled: root.grayscaleActive
        }

        Text {
            anchors.bottom: parent.bottom
            anchors.bottomMargin: vpx(16)
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Clic · B · Escape  →  cerrar zoom"
            font.pixelSize: vpx(11)
            font.letterSpacing: vpx(2)
            color: Qt.rgba(1, 1, 1, 0.35)
        }

        Rectangle {
            anchors.left: parent.left
            anchors.leftMargin: vpx(12)
            anchors.verticalCenter: parent.verticalCenter
            width: vpx(40)
            height: vpx(60)
            radius: vpx(4)
            color: zL.containsMouse ? Qt.rgba(1,1,1,0.15) : "transparent"
            visible: mediaUrls.length > 1
            Behavior on color { ColorAnimation { duration: 100 } }
            Text {
                anchors.centerIn: parent
                text: "‹"
                font.pixelSize: vpx(30)
                color: "white"
            }
            MouseArea {
                id: zL
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    mouse.accepted = true
                    sfx.playMove()
                    goPrev()
                }
            }
        }

        Rectangle {
            anchors.right: parent.right
            anchors.rightMargin: vpx(12)
            anchors.verticalCenter: parent.verticalCenter
            width: vpx(40)
            height: vpx(60)
            radius: vpx(4)
            color: zR.containsMouse ? Qt.rgba(1,1,1,0.15) : "transparent"
            visible: mediaUrls.length > 1
            Behavior on color { ColorAnimation { duration: 100 } }
            Text {
                anchors.centerIn: parent
                text: "›"
                font.pixelSize: vpx(30)
                color: "white"
            }
            MouseArea {
                id: zR
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    mouse.accepted = true
                    sfx.playMove()
                    goNext()
                }
            }
        }
    }

    Timer {
        id: closeTimer
        interval: 100
        onTriggered: root.closed()
    }

    focus: true
    Keys.onPressed: {
        if (zoomActive) {
            if (api.keys.isCancel(event) || event.key === Qt.Key_Escape) {
                event.accepted = true
                sfx.playMove()
                closeZoom()
                return
            }
            if (event.key === Qt.Key_Left || api.keys.isPrevPage(event)) {
                event.accepted = true
                sfx.playMove()
                goPrev()
                return
            }
            if (event.key === Qt.Key_Right || api.keys.isNextPage(event)) {
                event.accepted = true
                sfx.playMove()
                goNext()
                return
            }
            if (event.key === Qt.Key_G) {
                event.accepted = true
                sfx.playMove()
                root.grayscaleActive = !root.grayscaleActive
                return
            }
            event.accepted = true
            return
        }

        if (api.keys.isCancel(event) || event.key === Qt.Key_Escape) {
            event.accepted = true
            sfx.playMove()
            closeTimer.start()
            return
        }
        if (event.key === Qt.Key_Left || api.keys.isPrevPage(event)) {
            event.accepted = true
            sfx.playMove()
            goPrev()
            return
        }
        if (event.key === Qt.Key_Right || api.keys.isNextPage(event)) {
            event.accepted = true
            sfx.playMove()
            goNext()
            return
        }
        if (api.keys.isAccept(event) || event.key === Qt.Key_Return) {
            event.accepted = true
            sfx.playMove()
            if (mediaUrls.length > 0 && !root.currentIsVideo) openZoom()
                return
        }
        if (event.key === Qt.Key_G) {
            event.accepted = true
            sfx.playMove()
            root.grayscaleActive = !root.grayscaleActive
            return
        }
        event.accepted = true
    }
}
