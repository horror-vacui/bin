#!/bin/bash
# This script will restrict the tablet working area to the display, whose name is given as argument to the script (default is 'DP1'). The second optional argument is string to match the tablet name. If the tab;e;t name is defined as an argument, then the display name also needs to be specified.

DISPLAY_NAME=${1:-"DP1"}
TABLET_NAME=${2:-"TABLET"}

# check if the tablet with the specified name is connected
if xsetwacom --list devices | grep -q $TABLET_NAME; then
  # check if the display exists at all at the moment
  DISPLAYS=$(xrandr --listmonitors | grep -o '[^ ]*$')
    if echo "$DISPLAYS" | grep -wq $DISPLAY_NAME; then
    ID=$(xsetwacom --list devices | sed "/$TABLET_NAME/ s/.*id:\s\([0-9]\+\)\s.*/\1/")
    # restrict the tablet area to the specified display
    xsetwacom --set $ID MapToOutput $DISPLAY_NAME

    # The rest is calculating and setting the apprpriate area ratio on the tablet
    TMP=$(xrandr | sed -n "/\bDP1\b/,/^[^ ]/ p" | grep "*+")
    DISP_X=$(echo $TMP | sed "s/^\s*\([0-9]\+\)x\([0-9]\+\)\s.*/\1/")
    DISP_Y=$(echo $TMP | sed "s/^\s*\([0-9]\+\)x\([0-9]\+\)\s.*/\2/")
    DISP_RATIO=$(echo "$DISP_X/$DISP_Y" | bc -l)
    echo "Display ratio = $DISP_RATIO"

    TMP=$(xsetwacom --get $ID Area)
    T_X1=$(echo $TMP | cut -d " " -f3)
    # T_X2=$(echo $TMP | cut -d " " -f1) # =0
    T_Y1=$(echo $TMP | cut -d " " -f4)
    # T_Y2=$(echo $TMP | cut -d " " -f2) # =0
    T_RATIO=$(echo "$T_X1/$T_Y1" | bc -l)
    echo "Tablet ratio = $T_RATIO"

    if (( $(echo "$DISP_RATIO<$T_RATIO" | bc -l) )); then
      echo "Tablet X/Y ratio is greater than display's"
      # looks complicated due to the floating point to int conversion...
      T_X_NEW=$(echo "($(echo "$T_Y1/$DISP_Y*$DISP_X" | bc -l) +0.5/1" | bc)
      xsetwacom --set $ID Area 0 0 $T_X_NEW $T_Y1
    # do not do anything if the ratio is already correct
    elif (( $(echo "$DISP_RATIO>$T_RATIO" | bc -l) )); then 
      echo "Tablet X/Y ratio is smaller than screen's"
      T_Y_NEW=$(echo "($(echo "$DISP_Y/$DISP_X * $T_X1" | bc -l) +0.5)/1" | bc)
      echo $T_Y_NEW
      xsetwacom --set $ID Area 0 0 $T_X1 $T_Y_NEW
    else
      echo -e "The Tablet's X/Y ratio is the same as the display's.\nNothing to be done here. Exiting."  
    fi  
  fi  # display exists
fi # tablet exists
