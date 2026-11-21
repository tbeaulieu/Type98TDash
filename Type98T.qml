/****************************************************************************
** Based on the Qt examples (Copyright (C) 2012 Nokia Corporation), BSD
** license. See the original file header for the full license text.
****************************************************************************/

import QtQuick 2.3
import QtGraphicalEffects 1.0

import FileIO 1.0

Item{
    id:root

    property int udp_message:rpmtest.udp_packetdata
    // onUdp_messageChanged: console.log(" UDP is "+udp_message)

    property bool udp_up:udp_message&0x01
    property bool udp_down:udp_message&0x02
    property bool udp_left:udp_message&0x04
    property bool udp_right:udp_message&0x08
    property int odometer:if(speedunits==0)rpmtest.odometer0data;else rpmtest.odometer0data*0.621371
    property int tripmeter:if(speedunits==0)rpmtest.tripmileage0data;else rpmtest.tripmileage0data*0.621371
    property real rpm:rpmtest.rpmdata
    property real speed:rpmtest.speeddata
    property int speedunits:1             // 0 = KMH, 1 = MPH
    property real watertemp:rpmtest.watertempdata
    property real fuel:rpmtest.fueldata
    property real o2:rpmtest.o2data
    property real map:rpmtest.mapdata
    property real maf:rpmtest.mafdata
    property real oilpressure:rpmtest.oilpressuredata
    property real oiltemp: rpmtest.oiltempdata
    property real batteryvoltage:rpmtest.batteryvoltagedata

    property real symbols:rpmtest.symbolsdata
    property real symbols2:rpmtest.symbols2data

    property real gearpos:rpmtest.geardata

    property real rpmlimit:8000
    property real shiftvalue:0
    property string colorscheme: "green"
    property int red: 255
    property int green: 128
    property int blue: 100

    property real rpmdamping:1

    property real batterylow:0
    property real batteryhigh:0
    property real batteryunits:0

    // Wideband. o2data arrives as lambda; the limits are always in AFR (lambda x 14.7).
    property real afrlow:0                // 0 = no rich warning
    property real afrhigh:0               // 0 = no lean warning
    property int afrunits:1               // 0 = show lambda, 1 = show AFR
    property int afrshow:1                // 0 = hide the wideband readout
    property int mafshow:1                // 0 = hide the MAF readout

    // Defaults for a fresh install (no JSON and no old .txt to migrate)
    property int waterlow:80
    property int waterhigh:105
    property int waterunits:1
    property int fuellow:10
    property int fuelhigh:0
    property int fuelunits:1
    property int oiltemplow:0
    property int oiltemphigh:130
    property int oiltempunits:1
    property int oilpressurelow:1         // bar (the sender value is in bar)
    property int oilpressurehigh:0
    property int oilpressureunits:0
    property real night_time_hue:0

    // Optional readouts
    property int oiltempshow:1            // 0 = hide the oil temp readout
    property int oilpressureshow:1        // 0 = hide the oil pressure readout

    property bool settings_on_off:false
    property bool menu_on_off:rpmtest.settings_on_offdata&0x02

    onSettings_on_offChanged: {
        if(settings_on_off) rpmtest.settings_on_offdata=rpmtest.settings_on_offdata|0x01
        else rpmtest.settings_on_offdata=rpmtest.settings_on_offdata&~0x01
    }

    width:800
    height:480
    x: 0

    FontLoader {
        id: bdoGrotesk
        source: "./fonts/BDOGrotesk-VF.ttf"
    }
    ///////////////////////////////
    // Config (JSON)
    ///////////////////////////////

    FileIO {
        id: config_json
        source: "/opt/IC7/screen_configs/Type98T_config.json"
        onError: console.log(msg)
    }

    // Old positional files, read once for migration only.
    // v5+ firmware keeps them in /opt/IC7, v4 kept them in /opt/Garw_IC7.
    FileIO {
        id: config_file
        source: "/opt/IC7/screen_configs/Type98T_config.txt"
        onError: console.log(msg)
    }
    FileIO {
        id: config_file_v4
        source: "/opt/Garw_IC7/screen_configs/Type98T_config.txt"
        onError: console.log(msg)
    }

    // The schema. One entry per setting.
    //   disabled: true -> the property still exists (so the dial can bind to it),
    //   but it is hidden from the menu and not written to or read from the JSON.
    readonly property var schema: [
        { key: "colorscheme",      type: "string" },
        { key: "red" },  { key: "green" },  { key: "blue" },
        { key: "waterlow" },       { key: "waterhigh" },       { key: "waterunits" },
        { key: "fuellow" },
        { key: "oiltempshow" },    { key: "oiltemphigh" },     { key: "oiltempunits" },
        { key: "oilpressureshow" },{ key: "oilpressurelow" },
        { key: "speedunits" },     { key: "rpmlimit" },
        { key: "afrshow" },        { key: "afrunits" },        { key: "afrhigh" },        { key: "afrlow" },
        { key: "mafshow" },
        // the Type98T dial has nothing that uses these
        { key: "fuelhigh",         disabled: true },
        { key: "fuelunits",        disabled: true },
        { key: "oiltemplow",       disabled: true },
        { key: "oilpressureunits", disabled: true },
        { key: "oilpressurehigh",  disabled: true },
        { key: "shiftvalue",       disabled: true },
        { key: "night_time_hue",   disabled: true },
        { key: "rpmdamping",       disabled: true },
        { key: "batterylow",       disabled: true },
        { key: "batteryhigh",      disabled: true }
    ]

    // What the menu should list and what gets persisted
    readonly property var editableSettings: schema.filter(function(s) { return !s.disabled })

    // Old positional layout (line number -> key), used once for migration
    readonly property var legacyKeys: [
        "colorscheme", "red", "green", "blue",
        "waterlow", "waterhigh", "waterunits",
        "fuellow", "fuelhigh", "fuelunits",
        "oiltemplow", "oiltemphigh", "oiltempunits",
        "oilpressurelow", "oilpressurehigh", "oilpressureunits",
        "speedunits", "rpmlimit", "shiftvalue", "night_time_hue",
        "batterylow", "batteryhigh", "rpmdamping",
        null,                       // line 23 was unused
        "afrhigh", "afrlow"
    ]

    function schemaEntry(key) {
        for (var i = 0; i < schema.length; i++)
            if (schema[i].key === key) return schema[i]
        return null
    }

    // IC7 FileIO returns one line per open, so re-open for every line
    function readLines(f, maxLines) {
        var out = []
        for (var i = 0; i < maxLines; i++) {
            var s = ""
            try { f.openforreading(); s = f.readopenfile(i); f.close() }
            catch (e) { console.log("config read failed at line " + i + ": " + e) }
            if (s === "" || s === undefined || s === null) break
            out.push(String(s))
        }
        return out
    }

    function applyConfigValue(key, v) {
        var e = schemaEntry(key)
        if (!e || e.disabled) return
        if (e.type === "string") root[key] = String(v)
        else if (!isNaN(Number(v))) root[key] = Number(v)
    }

    // returns "json", "legacy", "none" or "error"
    function loadConfig() {
        var lines = readLines(config_json, 300)
        if (lines.length > 0) {
            try {
                var obj = JSON.parse(lines.join("\n"))
                for (var i = 0; i < editableSettings.length; i++) {
                    var k = editableSettings[i].key
                    if (obj.hasOwnProperty(k)) applyConfigValue(k, obj[k])
                }
                if (root.speedunits !== 0) root.speedunits = 1     // no "both" mode on this dial
                return "json"
            } catch (e) {
                console.log("config JSON invalid, keeping defaults and NOT overwriting: " + e)
                return "error"
            }
        }
        var old = readLines(config_file, 26)
        if (old.length === 0) old = readLines(config_file_v4, 26)
        if (old.length > 0) {
            for (var j = 0; j < old.length && j < legacyKeys.length; j++) {
                var lk = legacyKeys[j]
                // The old AFR High / Low never acted as limits on this dash, so they are not imported
                if (lk && lk !== "afrhigh" && lk !== "afrlow") applyConfigValue(lk, old[j])
            }
            if (root.speedunits !== 0) root.speedunits = 1     // no "both" mode on this dial
            // The old dash showed oil temp / oil pressure when their High was above zero.
            // Carry that over to the new Show settings.
            var oth = Number(old[legacyKeys.indexOf("oiltemphigh")])
            var oph = Number(old[legacyKeys.indexOf("oilpressurehigh")])
            root.oiltempshow     = (!isNaN(oth) && oth !== 0) ? 1 : 0
            root.oilpressureshow = (!isNaN(oph) && oph !== 0) ? 1 : 0
            return "legacy"
        }
        return "none"
    }

    function save_settings() {
        var obj = {}
        for (var i = 0; i < editableSettings.length; i++)
            obj[editableSettings[i].key] = root[editableSettings[i].key]
        try {
            config_json.open()
            config_json.writetoopenfile(JSON.stringify(obj, null, 2) + "\n")   // single write
            config_json.close()
        } catch (e) { console.log("config write failed: " + e) }
    }

    Component.onCompleted: {
        try { rpmtest.DISABLE_WARNING_OVERLAY = "YES_WARNINGS_HANDLED_LOCALLY" } catch (e) {}
        var r = loadConfig()
        if (r === "legacy" || r === "none") save_settings()   // migrate / seed defaults
    }

    ///////////////////////////////
    // Inputs (unchanged)
    ///////////////////////////////

    property int inputs:rpmtest.inputsdata

    //Inputs//31 max!!
    property bool ignition      :inputs&0x01
    property bool battery       :inputs&0x02
    property bool lapmarker     :inputs&0x04
    property bool rearfog       :inputs&0x08
    property bool mainbeam      :inputs&0x10
    property bool up_joystick   :inputs&0x20 || root.udp_up
    property bool leftindicator :inputs&0x40
    property bool rightindicator:inputs&0x80
    property bool brake         :inputs&0x100
    property bool oil           :inputs&0x200
    property bool seatbelt      :inputs&0x400
    property bool sidelight     :inputs&0x800
    property bool tripresetswitch     :inputs&0x1000
    property bool down_joystick :inputs&0x2000 || root.udp_down
    property bool doorswitch    :inputs&0x4000
    property bool airbag        :inputs&0x8000
    property bool tc            :inputs&0x10000
    property bool abs           :inputs&0x20000
    property bool mil           :inputs&0x40000
    property bool shift1_id     :inputs&0x80000
    property bool shift2_id     :inputs&0x100000
    property bool shift3_id     :inputs&0x200000
    property bool service_id    :inputs&0x400000
    property bool race_id       :inputs&0x800000
    property bool sport_id      :inputs&0x1000000
    property bool cruise_id     :inputs&0x2000000
    property bool reverse:inputs&0x4000000
    property bool handbrake :inputs&0x8000000
    property bool tc_off     :inputs&0x10000000
    property bool left_joystick :inputs&0x20000000 || root.udp_left
    property bool right_joystick:inputs&0x40000000 || root.udp_right

    onUp_joystickChanged: console.log("up")
    onDown_joystickChanged: console.log("down")
    onLeft_joystickChanged: console.log("left")
    onRight_joystickChanged: console.log("right")

    property bool movedown:left_joystick
    property bool moveup:right_joystick
    property bool increament:up_joystick
    property bool decreament:down_joystick

    ///////////////////////////////
    // Settings menu (new)
    ///////////////////////////////

    SettingsMenu {
        id: menu
        target: root
        open: root.settings_on_off
        labelFont: bdoGrotesk.name
        valueFont: bdoGrotesk.name
        z: 1
        onExitRequested: { root.settings_on_off = false; root.save_settings() }
    }

    onMovedownChanged: if (movedown && settings_on_off) menu.move(-1)
    onMoveupChanged:   if (moveup   && settings_on_off) menu.move(1)

    // up: opens the menu, otherwise changes the selected value
    onIncreamentChanged: {
        if (increament) {
            if (!settings_on_off) { if (!menu_on_off) settings_on_off = true }
            else if (!menu_on_off) menu.press(1)
        } else menu.release()
    }

    // down: changes the selected value
    onDecreamentChanged: {
        if (decreament) { if (settings_on_off) menu.press(-1) }
        else menu.release()
    }

    ///////////////////////////////
    // Dial: shrinks to a live preview while settings are open
    ///////////////////////////////

    // `screen` is the thing that shrinks when settings open. Anything inside it
    // (the Type98T dial and/or your pasted screen QML) shrinks together.
    Item {
        id: screen
        width: 800
        height: 480
        clip: true
        z: 0

        x: root.settings_on_off ? 120 : 0
        Behavior on x { NumberAnimation { duration: 500 } }
        y: root.settings_on_off ? 15 : 0
        Behavior on y { NumberAnimation { duration: 500 } }
        scale: root.settings_on_off ? 0.7 : 1.0
        Behavior on scale { NumberAnimation { duration: 500 } }
    Type98TDisplay  {
        id: dial
        odometer:root.odometer/10      // dial wants 6 digits
        tripmeter:root.tripmeter
        shiftvalue:root.shiftvalue
        rpm:root.rpm
        rpmlimit:root.rpmlimit
        rpmdamping:root.rpmdamping
        speed:root.speed
        speedunits: root.speedunits
        watertemp:root.watertemp
        waterhigh:root.waterhigh
        waterlow:root.waterlow
        waterunits: root.waterunits
        fuel:root.fuel
        fuelhigh:root.fuelhigh
        fuellow:root.fuellow
        fuelunits: root.fuelunits
        o2: root.o2
        afrlow: root.afrlow
        afrhigh: root.afrhigh
        afrunits: root.afrunits
        afrshow: root.afrshow
        mafshow: root.mafshow
        map: root.map
        maf: root.maf
        oilpressure: root.oilpressure
        oilpressurehigh:root.oilpressurehigh
        oilpressurelow:root.oilpressurelow
        oilpressureunits: root.oilpressureunits
        oiltemp: root.oiltemp
        oiltemphigh:root.oiltemphigh
        oiltemplow: root.oiltemplow
        oiltempunits: root.oiltempunits
        oiltempshow: root.oiltempshow
        oilpressureshow: root.oilpressureshow
        batteryvoltage: root.batteryvoltage
        userColor: Qt.rgba(root.red/255, root.green/255, root.blue/255, 1)
        gearpos: root.gearpos
        udp_message:root.udp_message
        inputs: root.inputs
        settingsFocus: menu.focusKey
        opacity: 1
        width: 800
        height: 480
        antialiasing: true
        clip: true
    }

    // =====================================================================
    //  PASTE YOUR SCREEN QML BELOW THIS LINE
    //  (items go here as siblings of Type98TDisplay; this whole `screen` Item
    //   shrinks when settings are open)
    //
    //  - Read live values as root.rpm, root.speed, root.watertemp, ...
    //    (anything declared at the top of this file)
    //  - Use `root.` rather than `parent.` for them: `parent` is now `screen`
    //  - If this replaces the Type98T dial, delete the Type98TDisplay { } block above
    // =====================================================================




    // =====================================================================
    //  PASTE YOUR SCREEN QML ABOVE THIS LINE
    // =====================================================================
    }   // end of `screen`


    GridBackground {
        anchors.fill: parent
        z: -1
        opacity: root.settings_on_off ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 500 } }
        visible: opacity > 0
        backColor:   "#06100c"   // gap colour, top
        backColor2:  "#030806"   // gap colour bottom, fog and vignette
        tileColor:    Qt.rgba(root.red/255, root.green/255, root.blue/255, 1)   // tile, lower half of its gradient
        tileColor2:  Qt.rgba(root.red/255, root.green/255, root.blue/255, .2)   // tile, upper half
        edgeColor:   "#dddddd"   // rim light on the tile edges
        accentColor: "#ffd400"   // the odd glowing tile
        tilt: .7
    }
}
