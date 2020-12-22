#!/bin/bash
# I've rotated the tablet with 180 degrees. So the cable is not in the way.
# To Do: find a way how could this be merged with other programs
# Buttons from top to bottom in inkscape:
# - ESC       
# - F6        Review Tools
# - 4         Highlight text (review tool)
# - 3         Freehand drawing
# - 6         Polygon
# - Ctrl+4    Text selection
# - Ctrl+1    Browse mode
# - Ctrl+s    save

xsetwacom --set "UC-LOIC TABLET 1060 Pad pad" Button 1 "key +ctrl s -ctrl"
xsetwacom --set "UC-LOIC TABLET 1060 Pad pad" Button 2 "key +ctrl 1 -ctrl"
xsetwacom --set "UC-LOIC TABLET 1060 Pad pad" Button 3 "key +ctrl 4 -ctrl"
xsetwacom --set "UC-LOIC TABLET 1060 Pad pad" Button 8 "key 6"
xsetwacom --set "UC-LOIC TABLET 1060 Pad pad" Button 9 "key 3"
xsetwacom --set "UC-LOIC TABLET 1060 Pad pad" Button 10 "key 4"
xsetwacom --set "UC-LOIC TABLET 1060 Pad pad" Button 11 "key f6"
xsetwacom --set "UC-LOIC TABLET 1060 Pad pad" Button 12 "key Escape"


