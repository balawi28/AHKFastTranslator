
# ![Sprite-0003](https://user-images.githubusercontent.com/41299807/179816059-ee64df15-9f64-4798-b268-62bbf79e1376.png) TrayAudioVisualizer
AutoHotKey (AHK) script to visualize current audio levels through dynamic vertical bars in the tray icon.

![Animation](https://user-images.githubusercontent.com/41299807/179812864-d4cb2667-3def-4435-8302-82d6bafc95b8.gif)

![Animation2](https://user-images.githubusercontent.com/41299807/179813181-9edc23e3-dc02-4ae0-b78b-920e1bc1cec8.gif)

## Application Features
- Helps to find out if any audio is currently playing in the background without the need to unmute the volume.
- A lightweight tool to help mute users find out whether the PC is playing audio or not.
- One-file-program, no need to install or set up a folder.
- It can be run automatically at startup.
- Custom color for the audio bars:

![image](https://user-images.githubusercontent.com/41299807/179814079-ca57247a-5509-4bb5-9af5-5ffeaff920cb.png)


## How To Install
1. Install AutoHotKey (https://www.autohotkey.com).
2. Download `Gdip.ahk` from [here](https://github.com/tariqporter/Gdip/blob/master/Gdip.ahk).
3. Download `VA.ahk` from [here](https://github.com/SaifAqqad/VA.ahk/blob/master/VA.ahk).
4. Download `TrayAudioVisualizer.ahk` from this repo.
5. Put all 3 `.ahk` scripts in the same folder and run `TrayAudioVisualizer.ahk`.

## Notes
- For suggestions and bug-reporting, please refer to the issues section of this page.
- This is not a spectrum analyzer, the bars represent the Current_Audio_Level $\pm$ random noise.