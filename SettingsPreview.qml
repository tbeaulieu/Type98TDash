import QtQuick 2.3

// Standalone preview: no rpmtest / FileIO / Type98TDisplay needed.
// Keys:  Left/Right = select   Up/Down = change (hold to repeat)
//        Space = open / close the menu
Item {
    id: root
    width: 800
    height: 480
    focus: true

    // Stand-in for the real root: same property names the menu edits.
    QtObject {
        id: fake
        property int red: 255
        property int green: 128
        property int blue: 100
        property real night_time_hue: 0
        property int speedunits: 0
        property real rpmlimit: 4000
        property real shiftvalue: 0
        property real rpmdamping: 1
        property int waterunits: 1
        property int waterhigh: 105
        property int waterlow: 60
        property int fuelhigh: 100
        property int fuellow: 10
        property int oiltempunits: 1
        property int oiltemphigh: 130
        property int oiltemplow: 40
        property int oilpressureunits: 0
        property int oilpressurehigh: 80
        property int oilpressurelow: 10
        property real batteryhigh: 14.8
        property real batterylow: 11.5
        property real afrhigh: 16.0
        property real afrlow: 11.0
        property int oiltempshow: 1
        property int oilpressureshow: 1
    }

    property bool settingsOn: true

    Rectangle { anchors.fill: parent; color: "#000000"; z: -1 }

    // Placeholder for the dial: shrinks like the real one and
    // takes its colour from the Red/Green/Blue rows so you can see them work.
    Rectangle {
        width: 800; height: 480
        color: Qt.rgba(fake.red / 255, fake.green / 255, fake.blue / 255, 1)
        opacity: 0.85
        x: root.settingsOn ? 160 : 0
        scale: root.settingsOn ? 0.55 : 1.0
        Behavior on x     { NumberAnimation { duration: 500 } }
        Behavior on scale { NumberAnimation { duration: 500 } }
        Text { anchors.centerIn: parent; text: "DIAL"; font.pixelSize: 120; color: "#000000"; opacity: 0.3 }
    }

    SettingsMenu {
        id: menu
        target: fake
        open: root.settingsOn
        z: 1
        onExitRequested: root.settingsOn = false
    }

    Keys.onPressed: {
        if (event.isAutoRepeat) return
        if (event.key === Qt.Key_Space) root.settingsOn = !root.settingsOn
        else if (!root.settingsOn) return
        else if (event.key === Qt.Key_Left)  menu.move(-1)
        else if (event.key === Qt.Key_Right) menu.move(1)
        else if (event.key === Qt.Key_Up)    menu.press(1)
        else if (event.key === Qt.Key_Down)  menu.press(-1)
    }
    Keys.onReleased: {
        if (event.isAutoRepeat) return
        if (event.key === Qt.Key_Up || event.key === Qt.Key_Down) menu.release()
    }
}
