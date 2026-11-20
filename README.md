![image](https://github.com/user-attachments/assets/ba654bf6-703d-4201-827a-5ebbf28f16c3)

# Type98TDash

 QML Dashboard for the Lotus GAWR dashboard.

 There's a section in `Type98TDisplay.qml` (search for "AIT/Wideband") to comment out if you are not running a wideband/Air intake temp sensor.

## Layout

- `Type98T.qml` - entry file: live data, config load/save, joystick handling, settings menu
- `Type98TDisplay.qml` - the dial itself
- `SettingsMenu.qml`, `SettingBox.qml`, `MonoText.qml`, `Theme.qml`, `GridBackground.qml` - settings menu (shared with AgeSolo)
- `SettingsPreview.qml` - standalone menu preview, not loaded by the dash
- `Type98T.qml.png` - preview shown in the dash picker

Settings are saved as JSON in `/opt/IC7/screen_configs/Type98T_config.json`. An existing `Type98T_config.txt` is imported once on first run.

---

# Installation notes:

1) Obtain the GARW dash installer here: https://github.com/dustinsterk/GARWDashUploader
2) You will need to unzip this dashboard file, rename the folder to "Type98T" (Don't use the quotes), and recompress it. (I know, it's a pain)
3) Upload the dash via the uploader while connected to the GAWR Wifi.
4) Follow the rest of the aforementioned instructions.

There are some prebuilt releases for the uploader, check with the Discord Channel here: https://discord.gg/bmKFrt8XP6
