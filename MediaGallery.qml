import QtQuick 2.15
import QtGraphicalEffects 1.15

Item {
    id: root

    property var   game:     null
    property color bgColor:  "#F5F0E8"
    property color inkBlack: "#1A1A1A"
    property color inkFaint: "#AAAAAA"
    property color divColor: "#DDDDDD"

    signal closed()

    function buildMediaList(g) {
        if (!g) return []
        var a    = g.assets
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
        add(a.banner);      add(a.poster);      add(a.boxFront)
        add(a.boxBack);     add(a.boxFull);     add(a.cartridge)
        add(a.logo);        add(a.tile);        add(a.steam)
        add(a.marquee);     add(a.bezel);       add(a.panel)
        add(a.cabinetLeft); add(a.cabinetRight)
        addList(a.screenshotList); addList(a.titlescreenList)
        addList(a.backgroundList); addList(a.bannerList); addList(a.posterList)
        return urls
    }

    property var  mediaUrls:  buildMediaList(game)
    property int  currentIdx: 0
    property bool zoomActive: false

    function goPrev()       { if (mediaUrls.length > 0) currentIdx = (currentIdx - 1 + mediaUrls.length) % mediaUrls.length }
    function goNext()       { if (mediaUrls.length > 0) currentIdx = (currentIdx + 1) % mediaUrls.length }
    function openZoom()     { zoomActive = true  }
    function closeZoom()    { zoomActive = false }
    function closeGallery() { root.closed() }

    Component.onCompleted: root.forceActiveFocus()

    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.72)
        MouseArea { anchors.fill: parent; onClicked: { if (!zoomActive) closeGallery() } }
    }

    Rectangle {
        id: card
        anchors.centerIn: parent
        width:  Math.min(parent.width  * 0.96, vpx(1100))
        height: Math.min(parent.height * 0.92, vpx(700))
        color:  bgColor
        radius: vpx(6)

        MouseArea { anchors.fill: parent; onClicked: {} }

        Item {
            id: header
            anchors { top: parent.top; left: parent.left; right: parent.right }
            height: vpx(40)

            Text {
                anchors.centerIn: parent
                text: mediaUrls.length > 0 ? (currentIdx + 1) + " / " + mediaUrls.length : "Sin imágenes"
                font.pixelSize: vpx(12); font.letterSpacing: vpx(3)
                color: inkFaint
            }

            Rectangle {
                anchors.right: parent.right; anchors.rightMargin: vpx(10)
                anchors.verticalCenter: parent.verticalCenter
                width: vpx(28); height: vpx(28); radius: vpx(4)
                color: closeHover.containsMouse ? inkBlack : "transparent"
                border.color: inkFaint; border.width: 1
                Behavior on color { ColorAnimation { duration: 100 } }
                Text {
                    anchors.centerIn: parent; text: "✕"; font.pixelSize: vpx(12)
                    color: closeHover.containsMouse ? bgColor : inkFaint
                    Behavior on color { ColorAnimation { duration: 100 } }
                }
                MouseArea {
                    id: closeHover; anchors.fill: parent
                    hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                    onClicked: closeGallery()
                }
            }

            Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 1; color: divColor }
        }

        Item {
            id: viewZone
            anchors { top: header.bottom; left: parent.left; right: parent.right; bottom: thumbStrip.top }
            clip: true

            Text {
                anchors.centerIn: parent
                visible: mediaUrls.length === 0
                text: "This game has no images."
                font.pixelSize: vpx(14); font.letterSpacing: vpx(2); color: inkFaint
            }

            GrayscaleImage {
                id: mainImage
                anchors.fill: parent; anchors.margins: vpx(12)
                source:   mediaUrls.length > 0 ? mediaUrls[currentIdx] : ""
                fillMode: Image.PreserveAspectFit
            }

            Rectangle {
                anchors.centerIn: parent
                width: vpx(6); height: vpx(6); radius: vpx(3); color: inkFaint
                visible: mediaUrls.length > 0 && mainImage.paintedWidth === 0
                SequentialAnimation on opacity {
                    loops: Animation.Infinite
                    NumberAnimation { to: 0.1; duration: 500 }
                    NumberAnimation { to: 1.0; duration: 500 }
                }
            }

            MouseArea {
                anchors.fill: parent
                anchors.leftMargin: vpx(44); anchors.rightMargin: vpx(44)
                property real startX: 0
                property bool dragging: false
                onPressed:         { startX = mouse.x; dragging = false }
                onPositionChanged: { if (Math.abs(mouse.x - startX) > vpx(10)) dragging = true }
                onReleased: {
                    if (!dragging) return
                    if      (mouse.x - startX < -vpx(30)) goNext()
                    else if (mouse.x - startX >  vpx(30)) goPrev()
                }
                onDoubleClicked: { if (mediaUrls.length > 0) openZoom() }
                cursorShape: Qt.OpenHandCursor
            }

            Rectangle {
                anchors.left: parent.left; anchors.leftMargin: vpx(6)
                anchors.verticalCenter: parent.verticalCenter
                width: vpx(34); height: vpx(54); radius: vpx(4)
                color: aL.containsMouse ? inkBlack : Qt.rgba(0,0,0,0.12)
                visible: mediaUrls.length > 1
                Behavior on color { ColorAnimation { duration: 100 } }
                Text { anchors.centerIn: parent; text: "‹"; font.pixelSize: vpx(26)
                    color: aL.containsMouse ? bgColor : inkFaint
                    Behavior on color { ColorAnimation { duration: 100 } }
                }
                MouseArea { id: aL; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: goPrev() }
            }

            Rectangle {
                anchors.right: parent.right; anchors.rightMargin: vpx(6)
                anchors.verticalCenter: parent.verticalCenter
                width: vpx(34); height: vpx(54); radius: vpx(4)
                color: aR.containsMouse ? inkBlack : Qt.rgba(0,0,0,0.12)
                visible: mediaUrls.length > 1
                Behavior on color { ColorAnimation { duration: 100 } }
                Text { anchors.centerIn: parent; text: "›"; font.pixelSize: vpx(26)
                    color: aR.containsMouse ? bgColor : inkFaint
                    Behavior on color { ColorAnimation { duration: 100 } }
                }
                MouseArea { id: aR; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: goNext() }
            }
        }

        Item {
            id: thumbStrip
            anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
            height: vpx(78); clip: true

            Rectangle { anchors.top: parent.top; width: parent.width; height: 1; color: divColor }

            ListView {
                id: thumbList
                anchors.fill: parent; anchors.margins: vpx(6)
                orientation: ListView.Horizontal; spacing: vpx(6)
                model: mediaUrls.length
                currentIndex: root.currentIdx
                highlightMoveDuration: 200; clip: true
                onCurrentIndexChanged: positionViewAtIndex(currentIndex, ListView.Center)

                delegate: Rectangle {
                    width: vpx(80); height: vpx(54); radius: vpx(3)
                    color: "transparent"
                    clip: true
                    border.color: index === root.currentIdx ? inkBlack : "transparent"
                    border.width: 2

                    GrayscaleImage {
                        anchors.fill: parent
                        anchors.margins: vpx(2)
                        source:   mediaUrls[index]
                        fillMode: Image.PreserveAspectFit
                        opacity:  index === root.currentIdx ? 1.0 : 0.45
                        Behavior on opacity { NumberAnimation { duration: 120 } }
                        z: -1

                    }

                    MouseArea {
                        anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                        onClicked: root.currentIdx = index
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

        MouseArea { anchors.fill: parent; onClicked: closeZoom() }

        GrayscaleImage {
            anchors.fill: parent; anchors.margins: vpx(32)
            source:   mediaUrls.length > 0 ? mediaUrls[currentIdx] : ""
            fillMode: Image.PreserveAspectFit
        }

        Text {
            anchors.bottom: parent.bottom; anchors.bottomMargin: vpx(16)
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Clic · B · Escape  →  cerrar zoom"
            font.pixelSize: vpx(11); font.letterSpacing: vpx(2)
            color: Qt.rgba(1, 1, 1, 0.35)
        }

        Rectangle {
            anchors.left: parent.left; anchors.leftMargin: vpx(12)
            anchors.verticalCenter: parent.verticalCenter
            width: vpx(40); height: vpx(60); radius: vpx(4)
            color: zL.containsMouse ? Qt.rgba(1,1,1,0.15) : "transparent"
            visible: mediaUrls.length > 1
            Behavior on color { ColorAnimation { duration: 100 } }
            Text { anchors.centerIn: parent; text: "‹"; font.pixelSize: vpx(30); color: "white" }
            MouseArea { id: zL; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                onClicked: { mouse.accepted = true; goPrev() } }
        }

        Rectangle {
            anchors.right: parent.right; anchors.rightMargin: vpx(12)
            anchors.verticalCenter: parent.verticalCenter
            width: vpx(40); height: vpx(60); radius: vpx(4)
            color: zR.containsMouse ? Qt.rgba(1,1,1,0.15) : "transparent"
            visible: mediaUrls.length > 1
            Behavior on color { ColorAnimation { duration: 100 } }
            Text { anchors.centerIn: parent; text: "›"; font.pixelSize: vpx(30); color: "white" }
            MouseArea { id: zR; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                onClicked: { mouse.accepted = true; goNext() } }
        }
    }

    focus: true
    Keys.onPressed: {
        if (zoomActive) {
            if (api.keys.isCancel(event) || event.key === Qt.Key_Escape) { event.accepted = true; closeZoom(); return }
            if (event.key === Qt.Key_Left  || api.keys.isPrevPage(event)) { event.accepted = true; goPrev(); return }
            if (event.key === Qt.Key_Right || api.keys.isNextPage(event)) { event.accepted = true; goNext(); return }
            event.accepted = true; return
        }
        if (api.keys.isCancel(event) || event.key === Qt.Key_Escape) { event.accepted = true; closeGallery(); return }
        if (event.key === Qt.Key_Left  || api.keys.isPrevPage(event)) { event.accepted = true; goPrev(); return }
        if (event.key === Qt.Key_Right || api.keys.isNextPage(event)) { event.accepted = true; goNext(); return }
        if (api.keys.isAccept(event)   || event.key === Qt.Key_Return)  { event.accepted = true; if (mediaUrls.length > 0) openZoom(); return }
        event.accepted = true
    }
}
