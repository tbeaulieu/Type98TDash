import QtQuick 2.3

// One line in the settings list:  group tag | label | value
// The yellow slab is drawn by the ListView highlight, not here;
// this item only flips its text colours when it is the current row.
Item {
    id: row

    property var    theme
    property string groupTag: ""      // only set on the first row of a group
    property string label: ""
    property string valueText: ""
    property bool   current: false
    property string labelFont: ""
    property string valueFont: ""

    height: theme.rowH

    Text {
        x: 14
        anchors.verticalCenter: parent.verticalCenter
        width: 62
        text: row.groupTag
        color: row.current ? theme.ink : theme.textDim
        font.pixelSize: 11
        font.letterSpacing: 1
        elide: Text.ElideRight
    }

    Text {
        x: 84
        anchors.verticalCenter: parent.verticalCenter
        text: row.label
        color: row.current ? theme.ink : theme.text
        font.pixelSize: 16
        font.bold: true
        font.family: row.labelFont
        Behavior on color { ColorAnimation { duration: 80 } }
    }

    Text {
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: 28
        text: row.valueText
        color: row.current ? theme.ink : theme.text
        font.pixelSize: 22
        font.family: row.valueFont
        Behavior on color { ColorAnimation { duration: 80 } }
    }
}
