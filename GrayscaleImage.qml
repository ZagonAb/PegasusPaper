import QtQuick 2.15
import QtGraphicalEffects 1.15

Item {
    id: root
    property alias source:       img.source
    property alias fillMode:     img.fillMode
    property alias paintedWidth: img.paintedWidth
    property alias paintedHeight: img.paintedHeight

    property bool  showBorder:        false
    property color borderColor:       Qt.rgba(0, 0, 0, 0.30)

    property int   verticalAlignment: Image.AlignVCenter

    function calcY() {
        var free = parent.height - img.paintedHeight
        if (verticalAlignment === Image.AlignTop)    return 0
            if (verticalAlignment === Image.AlignBottom) return free
                return free / 2
    }

    Image {
        id: img
        anchors.fill: parent
        visible: false
        fillMode: Image.PreserveAspectFit
        asynchronous: true
    }

    ShaderEffect {
        x: (parent.width  - img.paintedWidth)  / 2
        y: root.calcY()
        width:  img.paintedWidth
        height: img.paintedHeight

        property variant source: img

        fragmentShader: "
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
    }

    Rectangle {
        visible: showBorder && img.paintedWidth > 0
        x: (parent.width  - img.paintedWidth)  / 2
        y: root.calcY()
        width:  img.paintedWidth
        height: img.paintedHeight
        color: "transparent"
        border.color: borderColor
        border.width: 3
    }
}
