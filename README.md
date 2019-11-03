# puGUI

Pascal mini GUI - port of Achim Döbler UGUI.

## API

Original [reference guide](https://embeddedlightning.com/download/reference-guide/?wpdmdl=205)

## Fonts

[TrueType font converter](https://github.com/JulStrat/ttf2ugui) available.

## Colors

http://www.rapidtables.com/web/color/RGB_Color.htm.

## Project structure

UG.PAS - Core.
UG_BTN.INC - UG_BUTTON implementation.
UG_TXT.INC - UG_TEXTBOX implementation.
UG_IMG.INC - UG_IMAGE implementation.

## Screenshots

### Windows

<img src="https://github.com/JulStrat/puGUI/blob/devop/Windows/s1.JPG">

<img src="https://github.com/JulStrat/puGUI/blob/devop/Windows/s2.JPG">

<img src="https://github.com/JulStrat/puGUI/blob/devop/Windows/s3.JPG">

<img src="https://github.com/JulStrat/puGUI/blob/devop/Windows/s4.JPG">

### Linux 

Raspberry Pi Model B, frame buffer device `/dev/fb0`.
```
mode "1824x984"
    geometry 1824 984 1824 984 16
    timings 0 0 0 0 0 0 0
    rgba 5/11,6/5,5/0,0/16
endmode
```
<img src="https://github.com/JulStrat/puGUI/blob/devop/Linux/s1.png">

<img src="https://github.com/JulStrat/puGUI/blob/devop/Linux/s2.png">

<img src="https://github.com/JulStrat/puGUI/blob/devop/Linux/s3.png">
