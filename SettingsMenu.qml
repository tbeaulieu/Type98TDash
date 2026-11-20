import QtQuick 2.3

// Two-level settings menu: groups on the left, that group's options on the right.
//
//   target : object that owns the live values (the old `root` Item); options are
//            read/written by property name, so config load/save is untouched.
//   open   : slide in / out.
//
// Button grammar (same as before): left/right MOVE, up/down ACT.
//   move(+1/-1)   next / previous box in the active column
//   press(+1/-1)  on a group: open it (or Save & exit)
//                 on "Back": return to the groups
//                 on an option: change its value (numbers repeat until release())
//   release()     stop auto-repeat
Item {
    id: menu

    property var    target
    property bool   open: false
    property int    level: 0              // 0 = choosing a group, 1 = inside a group
    property int    cat: 0                // selected group
    property int    row: 1                // selected box in sub-list (0 = Back)
    property int    revision: 0           // bumped on change so value text refreshes
    property real   spin: 0               // header X rotation
    property real   pulse: 1              // 1 = white, 0 = black (shared by all boxes)
    property string labelFont: ""
    property string valueFont: ""
    property string title: "Settings"

    // Name of the value being edited ("waterhigh", "rpmlimit", ...) or "" when
    // closed / browsing groups. Hand to the subdash to highlight the matching gauge.
    readonly property string focusKey: (open && curRow) ? curRow.key : ""

    signal exitRequested()

    width: th.pad + th.catW + th.pad + th.flyW + th.pad
    height: 480

    Theme { id: th }

    // ------------------------------------------------------------------
    // Schema: groups, each with its rows. Glyph is optional for navigation. Order = navigation order.
    // number: min / max / step / wrap / decimals     enum: options[] by stored value
    // ------------------------------------------------------------------
    property var schema: [
        { name: "Display", rows: [
            { key: "red",            label: "Red",         type: "number", min: 0, max: 255, step: 1, wrap: true },
            { key: "green",          label: "Green",       type: "number", min: 0, max: 255, step: 1, wrap: true },
            { key: "blue",           label: "Blue",        type: "number", min: 0, max: 255, step: 1, wrap: true } ] },

        { name: "Drive", rows: [
            { key: "speedunits",     label: "Speed units", type: "enum",   options: ["KMH", "MPH", "BOTH"] },
            { key: "rpmlimit",       label: "Rpm limit",   type: "number", min: 0, max: 9000, step: 100, wrap: true } ] },

        { name: "Coolant", rows: [
            { key: "waterunits",     label: "Units", type: "enum",   options: ["F", "C"] },
            { key: "waterhigh",      label: "High",  type: "number", min: 0, step: 1 },
            { key: "waterlow",       label: "Low",   type: "number", min: 0, step: 1 } ] },

        { name: "Fuel", rows: [
            { key: "fuellow",        label: "Low",   type: "number", min: 0, step: 1 } ] },

        { name: "Oil temp", rows: [
            { key: "oiltempunits",   label: "Units", type: "enum",   options: ["F", "C"] },
            { key: "oiltemphigh",    label: "High",  type: "number", min: 0, step: 1 } ] },

        { name: "Oil press", rows: [
            { key: "oilpressurehigh",  label: "High",  type: "number", min: 0, step: 1 },
            { key: "oilpressurelow",   label: "Low",   type: "number", min: 0, step: 1 } ] },

        { name: "Save & Exit", action: true, glyph: '○', rows: [] }
    ]

    readonly property var curCat: schema[cat]
    readonly property var curRow: (level === 1 && row > 0) ? curCat.rows[row - 1] : null

    // ------------------------------------------------------------------
    // Logic
    // ------------------------------------------------------------------
    function format(r) {
        revision                                    // dependency: refresh on change
        var v = Number(target[r.key])
        if (r.type === "enum") {
            var o = r.options[Math.round(v)]
            return o !== undefined ? o : "?"
        }
        return v.toFixed(r.decimals || 0)
    }

    function adjust(dir) {
        var r = curRow
        if (!r) return
        var v = Number(target[r.key])
        if (r.type === "enum") {
            var n = r.options.length
            v = ((Math.round(v) + dir) % n + n) % n
        } else {
            v += dir * r.step
            if (r.max !== undefined && v > r.max) v = r.wrap ? r.min : r.max
            if (r.min !== undefined && v < r.min) v = r.wrap ? r.max : r.min
            v = Number(v.toFixed(r.decimals || 0))  // kills 0.1+0.2 style drift
        }
        target[r.key] = v
        revision++
    }

    function bump() {                               // visual feedback on any navigation
        spin += 90
        pulse = 1                                   // new selection always starts white
        pulseAnim.restart()
    }

    function move(dir) {
        repeater.stop()
        if (level === 0) {
            cat = (cat + dir + schema.length) % schema.length
        } else {
            var n = curCat.rows.length + 1          // +1 for Back
            row = (row + dir + n) % n
        }
        bump()
    }

    function press(dir) {
        if (level === 0) {
            if (curCat.action) { exitRequested(); return }
            level = 1
            row = 1
            bump()
            return
        }
        if (row === 0) { level = 0; bump(); return }   // Back
        adjust(dir)
        if (curRow && curRow.type === "number") {      // hold to repeat; enums step once
            repeater.dir = dir
            repeater.interval = 350
            repeater.restart()
        }
    }

    function release() { repeater.stop() }

    onOpenChanged: {
        repeater.stop()
        if (open) {
            level = 0
            revision++                              // pick up values loaded from the config file
            pulse = 1
            pulseAnim.restart()
        } else {
            pulseAnim.stop()
        }
    }

    Timer {
        id: repeater
        property int dir: 1
        repeat: true
        interval: 350                               // initial hold delay, then fast
        onTriggered: { menu.adjust(dir); interval = 80 }
    }

    SequentialAnimation {
        id: pulseAnim
        loops: Animation.Infinite
        NumberAnimation { target: menu; property: "pulse"; to: 0; duration: th.pulseMs; easing.type: Easing.InOutSine }
        NumberAnimation { target: menu; property: "pulse"; to: .4; duration: th.pulseMs; easing.type: Easing.InOutSine }
    }

    // ------------------------------------------------------------------
    // Header
    // ------------------------------------------------------------------
    Item {
        id: head
        width: menu.width
        height: th.headH
        x: menu.open ? 0 : -width
        Behavior on x { NumberAnimation { duration: th.slideMs; easing.type: Easing.OutCubic } }

        Item {
            x: 18; y: 18
            width: 28; height: 28
            rotation: menu.spin
            Behavior on rotation { NumberAnimation { duration: 180; easing.type: Easing.OutBack } }
            Rectangle { anchors.centerIn: parent; width: 36; height: 6; rotation: 45;  color: th.yellow }
            Rectangle { anchors.centerIn: parent; width: 36; height: 6; rotation: -45; color: th.yellow }
        }

        Text {
            x: 64
            anchors.verticalCenter: parent.verticalCenter
            text: menu.title
            color: th.white
            font.pixelSize: 28
            font.bold: true
            font.letterSpacing: 0
        }

        Text {                                      // breadcrumb while inside a group
            anchors.right: parent.right
            anchors.rightMargin: th.pad
            anchors.verticalCenter: parent.verticalCenter
            text: (menu.level === 1 && menu.curCat) ? menu.curCat.name : ""
            color: th.white
            font.pixelSize: 25
            font.bold: true
        }

        Rectangle { y: parent.height - 3; width: menu.width; height: 3; color: th.yellow }
        // Rectangle { y: parent.height - 3; x: 120; width: parent.width - 120; height: 3; color: th.black }
    }

    // ------------------------------------------------------------------
    // Group column (always fully visible, no scrolling)
    // ------------------------------------------------------------------
    Column {
        id: catCol
        y: th.headH + 10
        width: th.catW
        spacing: th.gap
        x: th.pad

        Repeater {
            model: menu.schema
            SettingBox {
                expand: true
                fullWidth: th.catW
                theme: th
                label: modelData.name
                selected: menu.level === 0 && index === menu.cat
                pinned:   menu.level === 1 && index === menu.cat
                pulse: menu.pulse
                shown: menu.open
                order: index
                labelFont: menu.labelFont
                glyph: modelData.glyph !== undefined ? modelData.glyph : "→"
            }
        }
    }

    // ------------------------------------------------------------------
    // Option column: always shows the selected group's options;
    // dimmed while browsing groups, full strength once inside.
    // ------------------------------------------------------------------
    Item {
         id: fly
        readonly property var items: menu.curCat ? [{ label: "Back", back: true }].concat(menu.curCat.rows) : []
        readonly property int count: items.length          // replaces the old count line
        readonly property bool shown: menu.open && menu.level === 1 && menu.curCat && !menu.curCat.action

        z: -1                                       // tucks behind the group column
        width: th.flyW
        height: count * th.boxH + (count - 1) * th.gap

        x: shown ? th.pad + th.catW + th.pad : th.pad + th.catW - 40
        Behavior on x { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }
        opacity: shown ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 120 } }
        visible: opacity > 0

        // level with its group, but never runs off the bottom
        y: Math.min(catCol.y + menu.cat * (th.boxH + th.gap),
                    menu.height - th.footH - 8 - height)
        Behavior on y { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }

        // opacity: !menu.open ? 0 : (menu.level === 1 ? 1.0 : 0.2)
        Behavior on opacity { NumberAnimation { duration: 160 } }
        Rectangle {                                 // solid backing: nothing shows through
            x: -6; y: -6
            width: fly.width + 12
            height: fly.height + 12
            z: -1
            color: th.panel
            border.width: 1
            border.color: th.boxFill
        }
        Column {
            spacing: th.gap
            Repeater {
                model: fly.items                              
                SettingBox {
                    property var r: modelData.back ? null : modelData   // was: index > 0 ? menu.curCat.rows[index - 1] : null
                    width: th.flyW
                    theme: th
                    label: r ? r.label : "Back"
                    valueText: r ? menu.format(r) : ""
                    selected: menu.level === 1 && index === menu.row
                    pulse: menu.pulse
                    shown: fly.shown
                    order: index
                    travel: 40
                    labelFont: menu.labelFont
                    valueFont: menu.valueFont
                }
            }
        }
    }

    // ------------------------------------------------------------------
    // Footer hint
    // ------------------------------------------------------------------
    Item {
        y: menu.height - th.footH
        width: menu.width
        height: th.footH
        opacity: menu.open ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 200 } }

        Rectangle { width: parent.width; height: 3; color: th.yellow }
        Text {
            x: th.pad
            anchors.verticalCenter: parent.verticalCenter
            text: menu.level === 0 ? "Left / Right: select      Up / Down: Open"
                                   : "Left / Right: select      Up / Down: Change/Accept"
            color: th.white
            font.pixelSize: 12
            font.bold: true
        }
    }
}
