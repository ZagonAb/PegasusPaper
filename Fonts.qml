import QtQuick 2.15

QtObject {
    id: root

    readonly property string lora:       loraLoader.name
    readonly property string publicSans: publicLoader.name

    property FontLoader loraLoader: FontLoader {
        id: loraLoader
        source: "assets/fonts/lora/lora.ttf"
    }

    property FontLoader publicLoader: FontLoader {
        id: publicLoader
        source: "assets/fonts/public/public.ttf"
    }
}
