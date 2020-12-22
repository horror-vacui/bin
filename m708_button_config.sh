#!/bin/bash
# Buttons from top to bottom in inkscape:
# - Ctrl+S    Save
# - Shift     Selection
# - Alt
# - "+"       Zoom-in
# - "-"       Zoom-out
# - Ctrl+V    Paste
# - Ctrl+X    Cut
# - Ctrl

xsetwacom --set "UC-LOIC TABLET 1060 Pad pad" Button 1 "key +ctrl s -ctrl"
xsetwacom --set "UC-LOIC TABLET 1060 Pad pad" Button 2 "key shift"
xsetwacom --set "UC-LOIC TABLET 1060 Pad pad" Button 3 "key alt"
xsetwacom --set "UC-LOIC TABLET 1060 Pad pad" Button 8 "key KP_Add"
xsetwacom --set "UC-LOIC TABLET 1060 Pad pad" Button 9 "key KP_Subtract"
xsetwacom --set "UC-LOIC TABLET 1060 Pad pad" Button 10 "key +ctrl v -ctrl"
xsetwacom --set "UC-LOIC TABLET 1060 Pad pad" Button 11 "key +ctrl x -ctrl"
xsetwacom --set "UC-LOIC TABLET 1060 Pad pad" Button 12 "key ctrl"


