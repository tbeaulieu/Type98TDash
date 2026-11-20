import QtQuick 2.3

// Design tokens. Everything visual in the menu pulls from here.
QtObject {
    // palette
    readonly property color white:    "#ffffff"
    readonly property color black:    "#000000"
    readonly property color boxFill:  "#474747"
    readonly property color panel:    "#0a1712"   // opaque flyout backing; match your BRG
    readonly property color yellow:   "#ffd400"   // header X mark only
    readonly property color textDim:  "#9a9a9a"
    readonly property color boxEdge:  "#CFCFCF"

    // boxes
    readonly property int borderW: 2
    readonly property int boxH:    36
    readonly property int gap:     4

    // layout
    readonly property int pad:   14
    readonly property int headH: 64
    readonly property int footH: 36
    readonly property int catW:  172              // group column
    readonly property int flyW:  206              // value column

    // motion
    readonly property int pulseMs: 700            // one white->black fade
    readonly property int slideMs: 220
    readonly property int stagger: 50
}
