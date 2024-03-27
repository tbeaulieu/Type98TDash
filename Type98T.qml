//Switch to 2.3 for Dash use... 6.2 is for preview in designer.
import QtQuick 2.3

//import Qt3D 1.0
import QtGraphicalEffects 1.0

//import QtGraphicalEffects 1.12
import FileIO 1.0
Item {


    /*#########################################################################
      #############################################################################
      Imported Values From GAWR inits
      #############################################################################
      #############################################################################
     */
    id: root
    property int myyposition: 0
    property int udp_message: rpmtest.udp_packetdata

    // onUdp_messageChanged: console.log(" UDP is "+udp_message)
    property bool udp_up: udp_message & 0x01
    property bool udp_down: udp_message & 0x02
    property bool udp_left: udp_message & 0x04
    property bool udp_right: udp_message & 0x08

    property int membank2_byte7: rpmtest.can203data[10]
    property int inputs: rpmtest.inputsdata

    //Inputs//31 max!!
    property bool ignition: inputs & 0x01
    property bool battery: inputs & 0x02
    property bool lapmarker: inputs & 0x04
    property bool rearfog: inputs & 0x08
    property bool mainbeam: inputs & 0x10
    property bool up_joystick: inputs & 0x20 || root.udp_up
    property bool leftindicator: inputs & 0x40
    property bool rightindicator: inputs & 0x80
    property bool brake: inputs & 0x100
    property bool oil: inputs & 0x200
    property bool seatbelt: inputs & 0x400
    property bool sidelight: inputs & 0x800
    property bool tripresetswitch: inputs & 0x1000
    property bool down_joystick: inputs & 0x2000 || root.udp_down
    property bool doorswitch: inputs & 0x4000
    property bool airbag: inputs & 0x8000
    property bool tc: inputs & 0x10000
    property bool abs: inputs & 0x20000
    property bool mil: inputs & 0x40000
    property bool shift1_id: inputs & 0x80000
    property bool shift2_id: inputs & 0x100000
    property bool shift3_id: inputs & 0x200000
    property bool service_id: inputs & 0x400000
    property bool race_id: inputs & 0x800000
    property bool sport_id: inputs & 0x1000000
    property bool cruise_id: inputs & 0x2000000
    property bool reverse: inputs & 0x4000000
    property bool handbrake: inputs & 0x8000000
    property bool tc_off: inputs & 0x10000000
    property bool left_joystick: inputs & 0x20000000 || root.udp_left
    property bool right_joystick: inputs & 0x40000000 || root.udp_right

    property int odometer: rpmtest.odometer0data/10*0.62 //Need to div by 10 to get 6 digits with leading 0
    property int tripmeter: rpmtest.tripmileage0data*0.62
    property real value: 0
    property real shiftvalue: 0

    property real rpm: rpmtest.rpmdata
    property real rpmlimit: 8000 //Originally was 7k, switched to 8000 -t
    property real rpmdamping: 5
    //property real rpmscaling:0
    property real speed: rpmtest.speeddata
    property int speedunits: 2

    property real watertemp: rpmtest.watertempdata
    property real waterhigh: 0
    property real waterlow: 80
    property real waterunits: 1

    property real fuel: rpmtest.fueldata
    property real fuelhigh: 0
    property real fuellow: 0
    property real fuelunits
    property real fueldamping

    property real o2: rpmtest.o2data
    property real map: rpmtest.mapdata
    property real maf: rpmtest.mafdata

    property real oilpressure: rpmtest.oilpressuredata
    property real oilpressurehigh: 0
    property real oilpressurelow: 0
    property real oilpressureunits: 0

    property real oiltemp: rpmtest.oiltempdata
    property real oiltemphigh: 90
    property real oiltemplow: 90
    property real oiltempunits: 1

    property real batteryvoltage: rpmtest.batteryvoltagedata

    property int mph: (speed * 0.62)

    property int gearpos: rpmtest.geardata

    property real masterbrightness: 1
    property real colourbrightness: 0.5

    property string colorscheme: "green"
    property int red: 0
    property int green: 0
    property int blue: 0
    property string red_value: if (red < 16)
                                   "0" + red.toString(16)
                               else
                                   red.toString(16)
    property string green_value: if (green < 16)
                                     "0" + green.toString(16)
                                 else
                                     green.toString(16)
    property string blue_value: if (blue < 16)
                                    "0" + blue.toString(16)
                                else
                                    blue.toString(16)

    //  onColorschemeChanged: console.log("color scheme is "+colorscheme)
    //property real masterbrightness:fuel/100

    //  onRed_valueChanged: console.log("red_value hex "+red_value)
    // onGreen_valueChanged: console.log("green_value hex "+green_value)
    // onBlue_valueChanged: console.log("blue_value hex "+blue_value)
    width: 800
    height: 480
    clip: true
    z: 0

    property real speed_spring: 1
    property real speed_damping: 1

    property real rpm_needle_spring: 3.0 //if(rpm<1000)0.6 ;else 3.0
    property real rpm_needle_damping: 0.2 //if(rpm<1000).15; else 0.2

    property bool changing_page: rpmtest.changing_pagedata
    //Commenting out this for possible future usage rather than deleting. -Tristan
    onChanging_pageChanged: if (changing_page) {

                                //                                temp_slider_colour_overlay.visible = false
                                //                                gauge_back4.visible = false
                                //                                oilp_slider_colour_overlay.visible = false
                                //                                gauge_back3.visible = false
                                //                                fuel_slider_colour_overlay.visible = false
                                //                                gauge_back.visible = false
                                //                                oilt_slider_colour_overlay.visible = false
                                //                                gauge_back2.visible = false
                            }
    //See Above reason for commenting out
    Component.onCompleted: delay_on_timer.start()
    Timer {
        id: delay_on_timer //this delay on timer is to delay the visibility of certain items , this gives a nice effect and stops opacity fade in of the screen looking crap
        interval: 500
        onTriggered: {

            //            temp_slider_colour_overlay.visible = true
            //            gauge_back4.visible = true
            //            oilp_slider_colour_overlay.visible = true
            //            gauge_back3.visible = true
            //            fuel_slider_colour_overlay.visible = true
            //            gauge_back.visible = true
            //            oilt_slider_colour_overlay.visible = true
            //            gauge_back2.visible = true
        }
    }

    //Tristan Generated Code Here:
    property string white_color: "#FFFFFF"
    property string primary_color: "#FFFFFF"; //#FFBF00 for amber
    property string night_light_color: "#BFFFAC"  //LCD Green
    property string sweetspot_color: "#FFA500" //Cam Changeover Rev colpr
    property string warning_red: "#FF0000" //Redline/Warning colors
    property string engine_warmup_color: "#eb7500"
    property string background_color: "#000000"
    x: 0
    y: 0

    //Fonts
    FontLoader {
        id: LEDCalculator
        source: "./fonts/LEDCalculator.ttf"
    }


    /* ########################################################################## */
    /* Main Layout items */
    /* ########################################################################## */
    Rectangle {
        id: background_rect
        y: 0
        width: 800
        height: 480
        color: root.background_color
        border.width: 0
        z: 0
    }
    Image{
        id: carbon_bkg
        y:0
        x:0
        z:0
        width: 800
        height: 480
        source: "./img/carbon_bkg.png"
    }
//    Item{
//        id: guides
//        Rectangle{
//            id: centerline
//            width: 1
//            height: 480
//            color: "#FFFF00"
//            x: 400

//        }
//        Rectangle{
//            id: gasline
//            width: 800
//            height: 1
//            color: "#FFFF00"
//            x: 0
//            y: 427
//        }

//    }

    Rectangle {
        id: rev_splitter
        y: 256
        x: 0
        z: 2
        width: 800
        height: 2
        color: if(!root.sidelight) root.primary_color; else root.night_light_color
    }

    Text {
        id: rpm_display_val
        text: root.rpm + " rpm"
        font.pixelSize: 32
        horizontalAlignment: Text.AlignRight
        font.pointSize: 32
        font.family: LEDCalculator.name
        x: 608
        y: 203
        z: 2
        width: 174
        opacity: 100
        color: if (root.rpm < 8000)
                   if(!root.sidelight) root.primary_color; else root.night_light_color
               else
                   root.warning_red
        Timer{
            id: rpm_shift_blink
            running: if(root.rpm >= 8000)
                        true
                    else
                        false
            interval: 60
            repeat: true
            onTriggered: if(parent.opacity === 0){
                parent.opacity = 100
            }
            else{
                parent.opacity = 0
            } 
        }
    }

    Text {
        id: watertemp_display_val
        text: root.watertemp.toFixed(
                  0) + "°" // Alec added toFixed(0) to have no decimal places
        font.pixelSize: 32
        font.pointSize: 32
        font.family: LEDCalculator.name
        width: 128
        height: 32
        x: 36
        y: 396
        z: 2
        color: if (root.watertemp < root.waterlow)
                    root.engine_warmup_color
                else if (root.watertemp > root.waterlow && root.watertemp < root.waterhigh)
                   if(!root.sidelight) root.primary_color; else root.night_light_color
               else
                   root.warning_red
    }

    Text {
        id: oiltemp_display_val
        font.pixelSize: 32
        font.pointSize: 32
        font.family: LEDCalculator.name
        width: 128
        height: 32
        x: 36
        y: 338
        z: 2
        color: if (root.oiltemp < root.oiltemphigh)
                   if(!root.sidelight) root.primary_color; else root.night_light_color
               else
                   root.warning_red
        text: root.oiltemp.toFixed(0) + "°" // "100°"
        visible: if(root.oiltemphigh === 0)false; else true
    }

    Text {
        id: oilpressure_display_val
        text: root.oilpressure.toFixed(0) //Alec added toFixed(0)
        font.pixelSize: 32
        font.pointSize: 32
        font.family: LEDCalculator.name
        width: 128
        height: 32
        x: 36
        y: 284
        z: 2
        color: if (root.oilpressure < root.oilpressurelow)
                    root.warning_red
                else
                    if(!root.sidelight) root.primary_color; else root.night_light_color
        visible: if(root.oilpressurehigh === 0)false; else true
    }
    Rectangle {
        id: oilpressure_line
        x: 16
        y: 327
        width: 256
        height: 2
        color: if(!root.sidelight) root.primary_color; else root.night_light_color
        visible: if(root.oilpressurehigh === 0)false; else true

    }

    Text {
        id: speed_display_val
        font.pixelSize: 56
        horizontalAlignment: Text.AlignRight
        font.family: LEDCalculator.name
        font.pointSize: 56
        x: 553
        y: 358
        width: 148
        color: if(!root.sidelight) root.primary_color; else root.night_light_color
        text: if (root.speedunits === 0){
                    root.speed.toFixed(0) //"0"   // Alec added speed
                }
                else{
                    root.mph.toFixed(0)
                }

        z: 2
    }

    Text {
        id: odometer_display_val
        text: if (root.speedunits === 0)
                root.odometer/.62 + " km"
                else if(root.speedunits === 1)
                root.odometer + " mi"
                else
                root.odometer
        font.pixelSize: 28
        horizontalAlignment: Text.AlignRight
        font.pointSize: 28
        font.family: LEDCalculator.name
        x: 618
        y: 440 //480 - 16 - 12
        z: 2
        width: 164
        color: if(!root.sidelight) root.primary_color; else root.night_light_color
    }

    Text {
        id: speed_label
        x: 707
        y: 396
        color: if(!root.sidelight) root.primary_color; else root.night_light_color
        text: if (root.speedunits === 0)
                "km/h"
                else if(root.speedunits === 1)
                "mi/h"
                else
                ""
        font.pixelSize: 32
        horizontalAlignment: Text.AlignRight
        z: 2
        font.family: LEDCalculator.name
        font.pointSize: 32
    }

    // RPM Marks
    Row {
        id: rpmLights
        x: 16
        y: 16
        width: 768
        height: 128
        layoutDirection: Qt.LeftToRight
        layer.enabled: true
        smooth: false
        clip: false
        z: 2
        Repeater {
            property int index
            z: 2
            model: 100
            Row {
                Rectangle {
                    height: 128

                    //Control for how the bar is lit
                    opacity: if (Math.floor(root.rpm / 100) > index + 1)
                                 .7
                             else if (Math.floor(root.rpm / 100) === index + 1)
                                 1
                             else
                                 .15

                    width: 3.68

                    //Settings for how our RPM colors are set
                    color: if (index < 59)
                            if(!root.sidelight) root.primary_color; else root.night_light_color
                    //Cam Changeover
                           else if (index >= 59 && index < 79)
                               root.sweetspot_color
                    //Redline
                           else
                               root.warning_red
                    radius: 2
                }
                Rectangle {
                    id: rpm_marker_spacer
                    height: 128
                    opacity: 1
                    width: 4
                    color: root.background_color
                    radius: 1
                    border.width: 0
                }
            }
        }
    }

    //Actual RPM marks
    Item {
        id: rev_system
        x: 16

        //Tic Marks
        Rectangle {
            id: ticmark_line
            width: 763
            height: 2
            x: 0
            y: 160
            z: 1
            color: if(!root.sidelight) root.primary_color; else root.night_light_color
        }
        Rectangle {
            id: tickmark_redline
            x: 609
            width: 153
            height: 2
            color: root.warning_red
            y: 160
            z: 2
        }

        Row {
            id: mainTicks
            x: 0
            y: 158
            width: 765
            height: 16
            antialiasing: true
            z: 2
            Rectangle {
                y: 0
                x: 73.8
                width: 6
                height: 18
                color: if (root.watertemp < 80) 
                    root.engine_warmup_color
                else
                   if(!root.sidelight) root.primary_color; else root.night_light_color
                border.color: root.background_color
                border.width: 2
                anchors.left: parent.left
                anchors.leftMargin: 0
            }
            Rectangle {
                y: 0
                width: 6
                height: 18
                color: if (root.watertemp < 80) 
                    root.engine_warmup_color
                else
                   if(!root.sidelight) root.primary_color; else root.night_light_color
                border.color: root.background_color
                border.width: 2
                anchors.left: parent.left
                anchors.leftMargin: 68
            }
            Rectangle {
                y: 0
                width: 6
                height: 18
                color: if (root.watertemp < 80) 
                    root.engine_warmup_color
                else
                   if(!root.sidelight) root.primary_color; else root.night_light_color
                border.color: root.background_color
                border.width: 2
                anchors.left: parent.left
                anchors.leftMargin: 144
            }
            Rectangle {
                y: 0
                width: 6
                height: 18
                color: if (root.watertemp < 80) 
                    root.engine_warmup_color
                else
                   if(!root.sidelight) root.primary_color; else root.night_light_color
                border.color: root.background_color
                border.width: 2
                anchors.left: parent.left
                anchors.leftMargin: 221
            }
            Rectangle {
                y: 0
                width: 6
                height: 18
                color: if (root.watertemp < 80) 
                    root.engine_warmup_color
                else
                   if(!root.sidelight) root.primary_color; else root.night_light_color
                border.color: root.background_color
                border.width: 2
                anchors.left: parent.left
                anchors.leftMargin: 298
            }
            Rectangle {
                y: 0
                width: 6
                height: 18
                color: if(!root.sidelight) root.primary_color; else root.night_light_color
                border.color: root.background_color
                border.width: 2
                anchors.left: parent.left
                anchors.leftMargin: 375
            }
            Rectangle {
                y: 0
                width: 6
                height: 18
                color: if(!root.sidelight) root.primary_color; else root.night_light_color
                border.color: root.background_color
                border.width: 2
                anchors.left: parent.left
                anchors.leftMargin: 452
            }
            Rectangle {
                y: 0
                width: 6
                height: 18
                color: if(!root.sidelight) root.primary_color; else root.night_light_color
                border.color: root.background_color
                border.width: 2
                anchors.left: parent.left
                anchors.leftMargin: 529
            }
            Rectangle {
                y: 0
                width: 6
                height: 18
                color: if(!root.sidelight) root.primary_color; else root.night_light_color
                border.color: root.background_color
                border.width: 2
                anchors.left: parent.left
                anchors.leftMargin: 605
            }
            Rectangle {
                y: 0
                width: 6
                height: 18
                color: if(!root.sidelight) root.primary_color; else root.night_light_color
                border.color: root.background_color
                border.width: 2
                anchors.left: parent.left
                anchors.leftMargin: 682
            }
            Rectangle {
                y: 0
                width: 6
                height: 18
                color: if(!root.sidelight) root.primary_color; else root.night_light_color
                border.color: root.background_color
                border.width: 2
                anchors.right: parent.right
                anchors.rightMargin: 0
            }
        }
                Row {
                    id: subTicks
                    x: 30
                    y: 160
                    width: 710
                    height: 16
                    antialiasing: true
                    z: 3
                    Repeater {
                        model: 8
                        property int index
                        Row {
                            id: subTickRow
                            width: 77

                            Rectangle {
                                width: 6
                                height: 13
                                x: 0
                                y: -2
                                border.color: root.background_color
                                border.width: 2
                                color: if (root.watertemp < 80) {
                                           if (index <= 3)
                                               root.engine_warmup_color
                                           else
                                            if(!root.sidelight) root.primary_color; else root.night_light_color

                                       } else
                                            if(!root.sidelight) root.primary_color; else root.night_light_color

    

                            }
                        }
                    }
                }
        Rectangle {
            id: engine_warmup_line
            x: 2
            y: 160
            width: 297
            height: 2
            z: 4
            color: root.engine_warmup_color
            visible: root.watertemp < 80
        }

        //RPM Numbers
        //Changed to Manual position as the alignment wasn't nice enough for my preferences
        Row {
            id: numbers
            x: 0
            y: 180
            height: 16
            width: 768
            Text {
                id: rev_zero
                x: 0
               color: if (root.watertemp < 80) 
                    root.engine_warmup_color
                else
                    if(!root.sidelight) root.primary_color; else root.night_light_color
                text: "0"
                font.pixelSize: 16
                horizontalAlignment: Text.AlignHCenter
                font.family: LEDCalculator.name
            }
            Text {
                id: rev_one
                color: if (root.watertemp < 80) 
                    root.engine_warmup_color
                else
                    if(!root.sidelight) root.primary_color; else root.night_light_color
                text: "1"
                anchors.left: parent.left
                font.pixelSize: 16
                horizontalAlignment: Text.AlignHCenter
                anchors.leftMargin: 65
                font.family: LEDCalculator.name
            }
            Text {
                id: rev_two
                color: if (root.watertemp < 80) 
                    root.engine_warmup_color
                else
                    if(!root.sidelight) root.primary_color; else root.night_light_color
                text: "2"
                font.pixelSize: 16
                horizontalAlignment: Text.AlignHCenter
                font.family: LEDCalculator.name
                anchors.leftMargin: 141
                anchors.left: parent.left
            }
            Text {
                id: rev_three
                color: if (root.watertemp < 80) 
                    root.engine_warmup_color
                else
                    if(!root.sidelight) root.primary_color; else root.night_light_color
                text: "3"
                font.pixelSize: 16
                horizontalAlignment: Text.AlignHCenter
                font.family: LEDCalculator.name
                anchors.leftMargin: 218
                anchors.left: parent.left
            }
            Text {
                id: rev_four
                color: if (root.watertemp < 80) 
                    root.engine_warmup_color
                else
                    if(!root.sidelight) root.primary_color; else root.night_light_color
                text: "4"
                font.pixelSize: 16
                horizontalAlignment: Text.AlignHCenter
                font.family: LEDCalculator.name
                anchors.leftMargin: 295
                anchors.left: parent.left
            }
            Text {
                id: rev_five
                color: if(!root.sidelight) root.primary_color; else root.night_light_color
                text: "5"
                font.pixelSize: 16
                horizontalAlignment: Text.AlignHCenter
                font.family: LEDCalculator.name
                anchors.leftMargin: 373
                anchors.left: parent.left
            }
            Text {
                id: rev_six
                color: if(!root.sidelight) root.primary_color; else root.night_light_color
                text: "6"
                font.pixelSize: 16
                horizontalAlignment: Text.AlignHCenter
                font.family: LEDCalculator.name
                anchors.leftMargin: 449
                anchors.left: parent.left
            }
            Text {
                id: rev_seven
                color: if(!root.sidelight) root.primary_color; else root.night_light_color
                text: "7"
                font.pixelSize: 16
                horizontalAlignment: Text.AlignHCenter
                font.family: LEDCalculator.name
                anchors.leftMargin: 526
                anchors.left: parent.left
            }
            Text {
                id: numba_eight
                color: if(!root.sidelight) root.primary_color; else root.night_light_color
                text: "8"
                font.pixelSize: 16
                horizontalAlignment: Text.AlignHCenter
                font.family: LEDCalculator.name
                anchors.leftMargin: 602
                anchors.left: parent.left
            }
            Text {
                id: rev_9
                color: if(!root.sidelight) root.primary_color; else root.night_light_color
                text: "9"
                font.pixelSize: 16
                horizontalAlignment: Text.AlignHCenter
                font.family: LEDCalculator.name
                anchors.rightMargin: 78
                anchors.right: parent.right
            }
            Text {
                id: rev_10
                x: 0
                y: 0
                color: if(!root.sidelight) root.primary_color; else root.night_light_color
                text: "10"
                anchors.right: parent.right
                font.pixelSize: 16
                horizontalAlignment: Text.AlignHCenter
                anchors.rightMargin: 0
                transformOrigin: Item.Right
                font.family: LEDCalculator.name
            }
        }

        Text {
            id: watertemp_label
            x: 113
            y: 410
            color: if (root.watertemp < root.waterlow)
                    root.engine_warmup_color
                else if (root.watertemp > root.waterlow && root.watertemp < root.waterhigh)
                   if(!root.sidelight) root.primary_color; else root.night_light_color
               else
                   root.warning_red
            text: "Water Temp °C"
            font.pixelSize: 16
            horizontalAlignment: Text.AlignHCenter
            font.family: LEDCalculator.name
        }

        Text {
            id: oiltemp_label
            x: 113
            y: 353
            color: if (root.oiltemp < root.oiltemphigh)
                       if(!root.sidelight) root.primary_color; else root.night_light_color
                   else
                       root.warning_red
            text: "Oil Temp °C"
            font.pixelSize: 16
            horizontalAlignment: Text.AlignHCenter
            font.family: LEDCalculator.name
            visible: if(root.oiltemphigh === 0)false; else true

        }

        Text {
            id: oilpressure_label
            x: 113
            y: 298
            color: if (root.oilpressure < root.oilpressurelow)
                    root.warning_red
                else
                    if(!root.sidelight) root.primary_color; else root.night_light_color
            text: "Oil Pressure"
            font.pixelSize: 16
            horizontalAlignment: Text.AlignHCenter
            font.family: LEDCalculator.name
            visible: if(root.oilpressurehigh === 0)false; else true

        }

        Text {
            id: fuel_label
            x: 321
            y: 431
            width: 128
            color: if (root.fuel > root.fuellow)
                       if(!root.sidelight) root.primary_color; else root.night_light_color
                   else
                       root.warning_red
            text: if (root.fuel > root.fuellow)
                      root.fuel + " %"
                  else
                      "LOW FUEL!!"
            font.pixelSize: 16
            horizontalAlignment: Text.AlignHCenter
            font.family: LEDCalculator.name
        }
    }

    Item {
        id: fueling_system
        x: 336
        y: 402
        width: 128
        height: 32
        Row {
            id: gasgauge
            x: 0
            y: -8
            width: 128
            height: 32
            antialiasing: true
            z: 3
            Repeater {
                model: 10
                //  required
                property int index
                Row {
                    Rectangle {
                        width: 11
                        height: 32
                        color: if (Math.floor(root.fuel / 10) > index) {
                                   if (root.fuel > 30)
                                       if(!root.sidelight) root.primary_color; else root.night_light_color
                                   else
                                       root.warning_red
                               } else
                                   "#0A0A0A"
                        radius: 2
                        border.width: if (Math.floor(root.fuel / 10) > index) {
                                          0
                                      } else
                                          1
                        border.color: if(!root.sidelight) root.primary_color; else root.night_light_color
                        z: 1
                    }
                    Rectangle {
                        width: 2
                        height: 32
                        color: root.background_color
                        z: 1
                    }
                }
            }
        }
    }
    Item {
        id: icons
        Image {
            id: brights
            x: 378
            y: 296
            height: 29
            width: 46
            source: "./img/brights.png"
            visible: root.mainbeam
        }
        Image{
            x: 285
            y: 301
            height: 17
            width: 49
            source: "./img/parking_lights.png"
            visible: root.sidelight
        }

        Image {
            id: left_blinker
            x: 341
            y: 295
            source: "./img/left_blinker.png"
            visible: root.leftindicator
        }
        Image {
            id: right_blinker
            x: 432
            y: 295
            source: "./img/right_blinker.png"
            visible: root.rightindicator
        }
        Image {
            id: battery_image
            x: 731
            y: 293
            width: 47
            height: 32
            source: "./img/battery_light.png"
            //autoTransform: false
            visible: root.battery
        }
        Image {
            id: cel_image
            x: 671
            y: 293
            width: 52
            source: "./img/cel_light.png"
            antialiasing: true
            height: 32
            visible: root.mil
        }

        Image {
            id: ebrake_image
            x: 569
            y: 295
            width: 96
            height: 32
            source: "./img/brake_light.png"
            visible: root.brake|root.handbrake //This is the way it is set in main.qml so trying this to see if it shows.
        }
        Image {
            id: tcs_image
            x: 531
            y: 295
            width: 43
            height: 32
            source: "./img/tcs_light.png"
            visible: root.tc
        }
        Image {
            id: oil_pressure_lamp
            x: 467
            source: "img/oil_light.png"
            y: 298
            width: 61
            height: 23
            visible: root.oil
        }

        Image {
            id: abs_image
            x: 333
            y: 349
            source: "./img/abs_light.png"
            sourceSize.width: 42
            sourceSize.height: 32
            visible: root.abs
        }
        Image {
            id: seatbelt_warning_lamp
            x: 390
            y: 349
            source: "./img/seatbelt_light.png"
            visible: root.seatbelt
        }
        Image {
            id: door_ajar_lamp
            x: 433
            y: 349
            source: "./img/door_light.png"
            visible: root.doorswitch
        }
        
    }
} //End Init Item

/*##^##
Designer {
    D{i:0}D{i:53;locked:true}
}
##^##*/
