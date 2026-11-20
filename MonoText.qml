import QtQuick 2.3

// Value text with fake monospacing: digits sit in fixed-width cells so numbers
// don't shuffle sideways as they change. Non-numeric text (KMH, PSI...) draws normally.
Item {
    id: mono

    property string text: ""
    property color  color: "white"
    property int    pixelSize: 22
    property string family: ""
    property bool   bold: false

    readonly property bool numeric: /^[0-9.,:%\-\s]+$/.test(text)
    readonly property real cell:   zero.implicitWidth      // digit cell = measured width of "0"
    readonly property real narrow: cell * 0.5              // . , -
    property int minCells: 0
    property int align: Qt.AlignRight
    implicitWidth: Math.max(numeric ? row.width : plain.implicitWidth, minCells * cell)
    implicitHeight: plain.implicitHeight

    Text {                                                  // measuring stick, never shown
        id: zero
        visible: false
        text: "0"
        font.pixelSize: mono.pixelSize
        font.family: mono.family
        font.bold: mono.bold
    }

    Text {
        id: plain
        visible: !mono.numeric
        text: mono.text
        color: mono.color
        font.pixelSize: mono.pixelSize
        font.family: mono.family
        font.bold: mono.bold
    }

    Row {
        id: row
        visible: mono.numeric
        Repeater {
            model: mono.numeric ? mono.text.length : 0
            Item {
                readonly property string ch: mono.text.charAt(index)
                width: /[0-9]/.test(ch) ? mono.cell : (ch === "%" ? mono.cell : mono.narrow)
                height: mono.implicitHeight
                Text {
                    anchors.centerIn: parent
                    text: parent.ch
                    color: mono.color
                    font.pixelSize: mono.pixelSize
                    font.family: mono.family
                    font.bold: mono.bold
                }
            }
        }
    }
}