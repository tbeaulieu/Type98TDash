import QtQuick 2.3

//   selected : fill fades white <-> black (driven by the shared `pulse`)
//   pinned   : solid fill; marks the group you came from while in the sub-list
//   shown    : animates in when true, out when false
//   order    : position in its column; staggers the cascade
//   expand   : true  -> starts as the arrow square on the left edge, pops in,
//                       then grows rightward to `fullWidth` (set fullWidth, not width)
//              false -> plain slide + fade (set width as usual)
Rectangle {
    id: box

    property var    theme
    property string label: ""
    property string valueText: ""
    property bool   selected: false
    property bool   pinned: false
    property real   pulse: 1                       // 1 = white, 0 = black
    property string labelFont: ""
    property string valueFont: ""
    property string glyph: r ? "→" : "←"

    // --- entrance / exit ---
    property bool   shown: true
    property int    order: 0
    property bool   expand: false
    property real   fullWidth: 0
    property real   travel: 40                     // slide distance when expand is false
    property bool appear: false
    Component.onCompleted: appear = true               // flips after creation, so the Behavior animates
    property real slide: (shown && appear) ? 1 : 0     // was: shown ? 1 : 0
    Behavior on slide {
        SequentialAnimation {
            // cascade: slow stagger on the way in, tight on the way out
            PauseAnimation { duration: box.order * (box.shown ? theme.stagger : (box.expand ? 0 : 25)) }
            NumberAnimation {
                duration: box.expand ? (box.shown ? 420 : 260)
                                     : (box.shown ? theme.slideMs : 160)
                easing.type: box.shown ? Easing.OutCubic : (box.expand ? Easing.InOutQuad : Easing.InCubic)
            }
        }
    }

    // expand mode, entering: first quarter = square pops in, rest = grows.
    // expand mode, leaving:  shrink and fade together in one motion (no 2nd phase).
    readonly property real pop:  shown ? Math.min(1, slide / 0.25) : 1
    readonly property real grow: shown ? Math.max(0, Math.min(1, (slide - 0.25) / 0.75)) : slide
    readonly property real textOn: expand ? Math.max(0, Math.min(1, (grow - 0.6) / 0.4)) : 1

    width:  expand ? theme.boxH + (fullWidth - theme.boxH) * grow : 100
    x:      0                                      // left edge stays put, right edge (and arrow) extends out
    height: theme.boxH
    clip: true
    // NB: no `visible: slide > 0` here. A Column drops invisible children from its
    // layout, so the column would collapse and re-flow mid-exit. opacity 0 isn't drawn.
    opacity: expand ? (shown ? pop : slide) : slide
    scale:   expand ? (shown ? 0.6 + 0.4 * pop : 1) : 1
    transformOrigin: Item.Left
    transform: Translate { x: box.expand ? 0 : -(1 - box.slide) * box.travel }

    color: selected ? Qt.rgba(pulse, pulse, pulse, 1)
                    : (pinned ? theme.textDim : theme.boxFill)
    border.width: theme.borderW
    border.color: theme.white
    radius: 0

    Text {
        x: 12
        anchors.verticalCenter: parent.verticalCenter
        text: box.label
        opacity: box.textOn
        color: theme.white
        font.pixelSize: 16
        font.bold: true
        font.family: box.labelFont
    }

    MonoText {
        anchors.right: parent.right
        anchors.rightMargin: 12
        anchors.verticalCenter: parent.verticalCenter
        text: box.valueText
        opacity: box.textOn
        color: theme.white
        pixelSize: 22
        family: box.valueFont
        bold: true
    }
    Rectangle{
        height: theme.boxH-2
        width: theme.boxH-2
        y:1
        x: parent.width - theme.boxH + 1
        opacity: box.valueText ? 0 : 1
        color: theme.boxEdge
        border.width: theme.borderW
        border.color: theme.white
        Text{
            x:9
            y:5
            font.pixelSize: 22
            font.family: box.labelFont
            font.bold: true
            text: box.glyph
        }
    }
}
