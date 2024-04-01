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
    property string primary_color: "#000000"; //#FFBF00 for amber
    property string night_light_color: "#BFFFAC"  //LCD Green
    property string sweetspot_color: "#FFA500" //Cam Changeover Rev colpr
    property string warning_red: "#FF0000" //Redline/Warning colors
    property string engine_warmup_color: "#eb7500"
    property string background_color: "#000000"
    x: 0
    y: 0

    //Fonts
    FontLoader {
        id: ledCalculator
        source: "./fonts/LEDCalculator.ttf"
    }
    FontLoader {
        id: bdoGrotesk
        source: "./fonts/BDOGrotesk-VF.ttf"
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
        x:0
        y:0
        z:0
        width: 800
        height: 480
        source: "./img/carbon_bkg.png"
    }
    Image{
        id: tachometer_bkg
        x: 166
        y: 6
        z: 1
        width: 468
        height: 468
        source: "./img/tach_bkg.png"
    }
    Item{
        id: tachometer_needle
        z: 4
        x: 396
        y: 60
        Image{
            height: 181
            width: 9
            source: './img/yellowneedle.png'
            antialiasing: true
            transform:
                Rotation {
                    id: tachneedle_rotate
                    origin.y: 181
                    origin.x: 4
                    angle: Math.min(Math.max(-192, Math.round((root.rpm/1000)*24) - 192), 48)                
                    Behavior on angle {
                        SpringAnimation {
                            spring: rpm_needle_spring
                            damping:rpm_needle_damping
                        }
                    }
                }
        }
    }

    Item{
        id: redline_tachometer_needle
        z: 4
        x: 396
        y: 60
        Image{
            height: 181
            width: 9
            source: './img/redline.png'
            antialiasing: true
            transform:
                Rotation {
                    id: redline_tachneedle_rotate
                    origin.y: 181
                    origin.x: 4
                    angle: Math.min(Math.max(-192, Math.round((root.rpmlimit/1000)*24) - 192), 48)                
                    Behavior on angle {
                        SpringAnimation {
                            spring: rpm_needle_spring
                            damping:rpm_needle_damping
                        }
                    }
                }
        }
    }
    Image{
        id: tach_center
        x: 339.5
        y: 179
        z: 5
        width: 121
        height: 127
        source: "./img/rev_center.png"
    }

    //Right Side Unit
    Item{
        id: right_side_information
        Image{
            id: lcd_background
            x: 645
            y: 16
            z: 2
            height: 448
            width: 139
            source: if(!root.sidelight)"./img/unlit_right_column.png";else "./img/lit_right_column.png"
        }
        Text {
        id: speed_display_val
        font.pixelSize: 48
        horizontalAlignment: Text.AlignRight
        font.family: ledCalculator.name
        x: 668
        y: 36
        z: 3
        width: 86
        color: if(!root.sidelight) root.primary_color; else root.night_light_color
        text: if (root.speedunits === 0){
                    root.speed.toFixed(0) 
                }
                else{
                    root.mph.toFixed(0)
                }
        }
        Text {
            id: speed_label
            x: 778
            y: if (root.speedunits === 0)
                    44
                    else if(root.speedunits === 1)
                    46
                    else
                    44
            color: if(!root.sidelight) root.primary_color; else root.night_light_color
            text: if (root.speedunits === 0)
                    "KM/H"
                    else if(root.speedunits === 1)
                    "MI/H"
                    else
                    ""
            font.pixelSize: 14
            horizontalAlignment: Text.AlignRight
            z: 2
            font.family: bdoGrotesk.name
            transform: Rotation{
                    angle: 90
                }
        }

        // This is doubled because we ALWAYS want to have a _solid_ value here, Opacity trigger gets messy
        Text {
            id: watertemp_display_val
            text: if(!root.waterunits((((root.watertemp.toFixed(0))*9)/5)+32).toFixed(0); else root.watertemp.toFixed(0)
            font.pixelSize: 48
            font.family: ledCalculator.name
            horizontalAlignment: Text.AlignRight
            width: 86
            height: 38
            x: 668
            y: 110
            z: 3
            
            color: if (root.watertemp < root.waterlow)
                        root.engine_warmup_color
                    else if (root.watertemp > root.waterlow && root.watertemp < root.waterhigh)
                    if(!root.sidelight) root.primary_color; else root.night_light_color
                else
                    root.warning_red
            visible: if(root.watertemp < root.waterhigh) true; else false
        }
        Text {
            id: watertemp_display_val_blink
            text: if(!root.waterunits)((((root.watertemp.toFixed(0))*9)/5)+32).toFixed(0); else root.watertemp.toFixed(0)
            font.pixelSize: 48
            font.family: ledCalculator.name
            horizontalAlignment: Text.AlignRight
            width: 86
            height: 38
            x: 668
            y: 110
            z: 3
            opacity: water_temp_animate.running ? 0 : 1
            color: if (root.watertemp < root.waterlow)
                        root.engine_warmup_color
                    else if (root.watertemp > root.waterlow && root.watertemp < root.waterhigh)
                    if(!root.sidelight) root.primary_color; else root.night_light_color
                else
                    root.warning_red
            Timer{
                id: water_temp_animate
                running: if (root.watertemp > root.waterhigh)
                            true
                        else
                            false
                interval: 500
                repeat: true
                onTriggered: if(parent.opacity === 0){
                    parent.opacity = 1
                }
                else{
                    parent.opacity = 0
                } 
            }
            visible: if(root.watertemp < root.waterhigh) false; else true
        }
         Text {
            id: watertemp_label
            x: 778
            y: 106
            z: 4
            color: if (root.watertemp < root.waterlow)
                    root.engine_warmup_color
                else if (root.watertemp > root.waterlow && root.watertemp < root.waterhigh)
                   if(!root.sidelight) root.primary_color; else root.night_light_color
               else
                   root.warning_red
            text: if(!root.waterunits) "WATER F"; else "WATER C"
            font.pixelSize: 14
            horizontalAlignment: Text.AlignHCenter
            font.family: bdoGrotesk.name
            transform: Rotation{
                angle: 90
            }
        }

        Text {
            id: oiltemp_display_val
            text: if(!root.oiltempunits)((((root.oiltemp.toFixed(0))*9)/5)+32).toFixed(0); else root.oiltemp.toFixed(0)
            font.pixelSize: 48
            font.family: ledCalculator.name
            horizontalAlignment: Text.AlignRight
            width: 86
            height: 38
            x: 668
            y: 186
            z: 3
            color: if(!root.sidelight) root.primary_color; else root.night_light_color
            visible: if(root.oiltemphigh === 0 && root.oiltemp < root.oiltemphigh)false; else true
            opacity: oil_temp_animate.running ? 0 : 1
            
        }
        Text {
            id: oiltemp_display_val_blink
            text: if(!root.oiltempunits)((((root.oiltemp.toFixed(0))*9)/5)+32).toFixed(0); else root.oiltemp.toFixed(0)
            font.pixelSize: 48
            font.family: ledCalculator.name
            horizontalAlignment: Text.AlignRight
            width: 86
            height: 38
            x: 668
            y: 186
            z: 3
            color: if (root.oiltemp < root.oiltemphigh)
                   if(!root.sidelight) root.primary_color; else root.night_light_color
               else
                   root.warning_red
            visible: if(root.oiltemphigh === 0)false; else true
            opacity: oil_temp_animate.running ? 0 : 1
            Timer{
                id: oil_temp_animate
                running: if (root.oiltemp > root.oiltemphigh)
                            true
                        else
                            false
                interval: 500
                repeat: true
                onTriggered: if(parent.opacity === 0){
                    parent.opacity = 1
                }
                else{
                    parent.opacity = 0
                }
            }
        }
         Text {
            id: oiltemp_label
            x: 778
            y: 194
            z: 4
            color: if (root.oiltemp < root.oiltemphigh)
                   if(!root.sidelight) root.primary_color; else root.night_light_color
               else
                   root.warning_red
            text: if(!root.oiltempunits) "OIL F"; else "OIL C"
            font.pixelSize: 14
            horizontalAlignment: Text.AlignHCenter
            font.family: bdoGrotesk.name
            transform: Rotation{
                angle: 90
            }
            visible: if(root.oiltemphigh === 0)false; else true

        }
         Text {
            id: oilpressure_display_val
            width: 86
            height: 38
            x: 668
            y: 262
            z: 3
            text: root.oilpressure.toFixed(0) 
            font.pixelSize: 48
            font.family: ledCalculator.name
            horizontalAlignment: Text.AlignRight
            color: if (root.oilpressure.toFixed(0) < root.oilpressurelow)
                        root.warning_red
                    else
                        if(!root.sidelight) root.primary_color; else root.night_light_color
            visible: if(root.oilpressurehigh === 0 || root.oilpressure.toFixed(0) < root.oilpressurelow)false; else true
            }
        Text {
            id: oilpressure_display_val_blink
            width: 86
            height: 38
            x: 668
            y: 262
            z: 3
            text: root.oilpressure.toFixed(0) 
            font.pixelSize: 48
            font.family: ledCalculator.name
            horizontalAlignment: Text.AlignRight
            color: if (root.oilpressure.toFixed(0) < root.oilpressurelow)
                        root.warning_red
                    else
                        if(!root.sidelight) root.primary_color; else root.night_light_color
            visible: if(root.oilpressurehigh !== 0 && root.oilpressure.toFixed(0) < root.oilpressurelow)true; else false
            opacity: oil_pressure_animate.running ? 0 : 1
            Timer{
                id: oil_pressure_animate
                running: if(root.oilpressure.toFixed(0) <= root.oilpressurelow)
                            true
                        else
                            false
                interval: 500
                repeat: true
                onTriggered: if(parent.opacity === 0){
                    parent.opacity = 1
                }
                else{
                    parent.opacity = 0
                } 
            }
        }

        Text {
            id: oilpressure_label
            x: 778
            y: 260
            z: 4
            color: if (root.oilpressure.toFixed(0) > root.oilpressurelow)
                   if(!root.sidelight) root.primary_color; else root.night_light_color
               else
                   root.warning_red
            text: "OIL PRS"
            font.pixelSize: 14
            horizontalAlignment: Text.AlignHCenter
            font.family: bdoGrotesk.name
            transform: Rotation{
                angle: 90
            }
            visible: if(root.oilpressurehigh === 0)false; else true

        }
        Text {
            id: fuel_display_val
            width: 86
            height: 38
            x: 668
            y: 336
            z: 3
            text: root.fuel.toFixed(0) 
            font.pixelSize: 48
            font.family: ledCalculator.name
            horizontalAlignment: Text.AlignRight
            opacity: gas_animate.running ? 0 : 1
            color: if(!root.sidelight) root.primary_color; else root.night_light_color
            Timer{
                id: gas_animate
                running: if(root.fuel <= root.fuellow)
                            true
                        else
                            false
                interval: 500
                repeat: true
                onTriggered: if(parent.opacity === 0){
                    parent.opacity = 1
                }
                else{
                    parent.opacity = 0
                } 
            }
        }
        Text {
            id: fuel_level_label
            x: 778
            y: 336
            z: 4
            color: if(!root.sidelight) root.primary_color; else root.night_light_color
            text: "FUEL %"
            font.pixelSize: 14
            horizontalAlignment: Text.AlignHCenter
            font.family: bdoGrotesk.name
            transform: Rotation{
                angle: 90
            }
        }


        Text {
            id: odometer_display_val
            text: if (root.speedunits === 0)
                    root.odometer/.62
                    else if(root.speedunits === 1)
                    root.odometer
                    else
                    root.odometer
            font.pixelSize: 24
            horizontalAlignment: Text.AlignRight
            font.family: ledCalculator.name
            x: 668
            y: 416
            z: 3
            width: 86
            color: if(!root.sidelight) root.primary_color; else root.night_light_color
        }
        Text {
            id: odometer_label
            x: 778
            y: 420
            z: 4
            color: if(!root.sidelight) root.primary_color; else root.night_light_color
            text: if (root.speedunits === 0)
                    "Km"
                    else if(root.speedunits === 1)
                    "Mi"
                    else
                    ""
            font.pixelSize: 14
            horizontalAlignment: Text.AlignHCenter
            font.family: bdoGrotesk.name
            transform: Rotation{
                angle: 90
            }
        }
    }

    Item{
        id: left_side_column
        Image{
            id: left_column_bkg
            x: 16
            y: 17
            z: 2
            height: 448
            width: 139
            source: "./img/left_column.png"
        }
        Image {
            id: dimLight1
            x: 34
            y: 36
            z: 4
            width: 31
            height: 31
            source: "./img/shift_lights_unlit.png"
        }
        Image {
            id: dimLight2
            x: 70
            y: 36
            z: 4
            width: 31
            height: 31
            source: "./img/shift_lights_unlit.png"
        }
        Image {
            id: dimLight3
            x: 106
            y: 36
            z: 4
            width: 31
            height: 31
            source: "./img/shift_lights_unlit.png"
        }
         Image{
            id: shiftLight1
            x: 30
            y: 32
            z: 5
            source: "./img/shift_lights_lit.png"
            visible: root.rpm >= root.rpmlimit - 1000 && root.rpm < root.rpmlimit ? true : false
         }
        Image{
            id: shiftLight1_blink
            x: 30
            y: 32
            z: 5
            source: "./img/shift_lights_lit.png"
            visible: root.rpm >= root.rpmlimit ? true : false
            Timer{
                id: rpm_shift_blink1
                running: if(root.rpm >= root.rpmlimit)
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
        Image{
            id: shiftLight2
            x: 66
            y: 32
            z: 5
            source: "./img/shift_lights_lit.png"
            visible: root.rpm >= root.rpmlimit - 500 && root.rpm < root.rpmlimit ? true : false
        }
        Image{
            id: shiftLight2_blink
            x: 66
            y: 32
            z: 5
            source: "./img/shift_lights_lit.png"
            visible: root.rpm >= root.rpmlimit ? true : false
            Timer{
            id: rpm_shift_blink2
            running: if(root.rpm >= root.rpmlimit)
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
        Image{
            id: shiftlight3
            x: 102
            y: 32
            z: 5
            source: "./img/shift_lights_lit.png"
            visible: root.rpm >= root.rpmlimit - 250 && root.rpm < root.rpmlimit ? true : false
        }
        Image{
            id: shiftLight3_blink
            x: 102
            y: 32
            z: 5
            source: "./img/shift_lights_lit.png"
            visible: root.rpm >= root.rpmlimit ? true : false
            Timer{
            id: rpm_shift_blink3
            running: if(root.rpm >= root.rpmlimit)
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
        Item{
            id: dummy_lights
            z:3
            Image {
                id: left_blinker
                x: 27
                y: 248
                source: "./img/left_blinker.png"
                visible: root.leftindicator
            }
            Image {
                id: right_blinker
                x: 90
                y: 248
                source: "./img/right_blinker.png"
                visible: root.rightindicator
            }
            Image {
                id: door_ajar_lamp
                x: 27
                y: 282
                source: "./img/door_light.png"
                visible: root.doorswitch
            }
            Image {
                id: ebrake_image
                x: 90
                y: 282
                source: "./img/ebrake_light.png"
                visible: root.brake|root.handbrake //This is the way it is set in main.qml so trying this to see if it shows.
            }
            Image {
                id: seatbelt_warning_lamp
                x: 27
                y: 316
                source: "./img/seatbelt_light.png"
                visible: root.seatbelt
            }
            Image {
                id: abs_image
                x: 90
                y: 316
                source: "./img/abs_light.png"
                visible: root.abs
            } 
            Image {
                id: battery_image
                x: 27
                y: 350
                source: "./img/battery_light.png"
                visible: root.battery
            }
            Image {
                id: oil_pressure_lamp
                x: 27
                y: 384
                source: "img/oil_light.png"
                visible: root.oil
            }
            Image {
                id: cel_image
                x: 90
                y: 384
                source: "./img/cel_light.png"
                visible: root.mil
            }
            Image {
                id: brights_image
                x: 27
                y: 418
                source: "./img/brights_light.png"
                visible: root.mainbeam
            }
            Image {
                id: srs_light
                x: 90
                y: 418
                source: "./img/srs_light.png"
                visible: root.airbag
            }

            // Image {
            //     id: tcs_image
            //     x: 531
            //     y: 295
            //     width: 43
            //     height: 32
            //     source: "./img/tcs_light.png"
            //     visible: root.tc
            // }
            

            
            
            
            
        }
    }

    

    Item {
        id: icons
        
        
    }
} //End Type98T Dash

/*##^##
Designer {
    D{i:0}D{i:53;locked:true}
}
##^##*/
