#!/bin/bash
# This script will restrict the tablet working area to the display, whose name is given as argument to the script (default is 'DP1'). The second optional argument is string to match the tablet name. If the tab;e;t name is defined as an argument, then the display name also needs to be specified.
# rotation: I find it easier to remember the degree

# saner programming env: these switches turn some bugs into errors
set -o errexit -o pipefail -o noclobber -o nounset

# -allow a command to fail with !’s side effect on errexit
# -use return value from ${PIPESTATUS[0]}, because ! hosed $?
! getopt --test > /dev/null 
if [[ ${PIPESTATUS[0]} -ne 4 ]]; then
    echo 'I’m sorry, `getopt --test` failed in this environment.'
    exit 1
fi

OPTIONS=d:p:t:r:
LONGOPTS=display:,pen:,tablet:,rotate:

# -regarding ! and PIPESTATUS see above
# -temporarily store output to be able to check for errors
# -activate quoting/enhanced mode (e.g. by writing out “--options”)
# -pass arguments only via   -- "$@"   to separate them correctly
! PARSED=$(getopt --options=$OPTIONS --longoptions=$LONGOPTS --name "$0" -- "$@")
if [[ ${PIPESTATUS[0]} -ne 0 ]]; then
    # e.g. return value is 1
    #  then getopt has complained about wrong arguments to stdout
    exit 2
fi
# read getopt’s output this way to handle the quoting right:
eval set -- "$PARSED"

DISPLAY_NAME="DP1" STYLUS_NAME="Pen" TABLET_NAME="Pad" ROTATE="0"
# now enjoy the options in order and nicely split until we see --
while true; do
    case "$1" in
        -d|--debug)  DISPLAY_NAME="$2"; shift ;;
        -p|--pen)    STYLUS_NAME="$2"; shift ;;
        -t|--tablet) TABLET_NAME="$2"; shift ;;
        -r|--rotate) ROTATE="$2"; shift 2 ;;
        --) shift; break ;;
        *)
            echo "Programming error"
            exit 3
            ;;
    esac
done
echo -e "${DISPLAY_NAME}\t${STYLUS_NAME}\t${TABLET_NAME}\t${ROTATE}"

# # handle non-option arguments
# if [[ $# -ne 1 ]]; then
#     echo "$0: A single input file is required."
#     exit 4
# fi


# DISPLAY_NAME=${1:-"DP1"}
# STYLUS_NAME=${2:-"Pen"}
# TABLET_NAME=${3:-"Pad"} # it is neded only for button config, which is done in another file

# check if the tablet with the specified name is connected
if xsetwacom --list devices | grep -q $TABLET_NAME; then
  # check if the display exists at all at the moment
  DISPLAYS=$(xrandr --listmonitors | grep -o '[^ ]*$')
    if echo "$DISPLAYS" | grep -wq $DISPLAY_NAME; then
    ID_STYLUS=$(xsetwacom --list devices | grep $STYLUS_NAME | sed "s/.*id:\s\([0-9]\+\)\s.*/\1/")
    # restrict the tablet area to the specified display
    xsetwacom --set $ID_STYLUS MapToOutput $DISPLAY_NAME

    # The rest is calculating and setting the apprpriate area ratio on the tablet
    TMP=$(xrandr | sed -n "/\bDP1\b/,/^[^ ]/ p" | grep "*+")
    DISP_X=$(echo $TMP | sed "s/^\s*\([0-9]\+\)x\([0-9]\+\)\s.*/\1/")
    DISP_Y=$(echo $TMP | sed "s/^\s*\([0-9]\+\)x\([0-9]\+\)\s.*/\2/")
    DISP_RATIO=$(echo "$DISP_X/$DISP_Y" | bc -l)
    echo -e "Display ratio = $DISP_RATIO\t=\t${DISP_X}/${DISP_Y}\tx/y"

    TMP=$(xsetwacom --get $ID_STYLUS Area | xargs -n1 | sort -gr | xargs)
    read -ra arr <<< "$TMP"
    T_X=${arr[0]} # MAX
    T_Y=${arr[1]} # 2nd MAX
    T_RATIO=$(echo "${T_X}/${T_Y}" | bc -l)
    echo -e "Tablet ratio = ${T_RATIO}\tX:Y = ${T_X} : ${T_Y}"
    

    if (( $(echo "${DISP_RATIO}<${T_RATIO}" | bc -l) )); then
      echo "Tablet X/Y ratio is greater than display's"
      # looks complicated due to the floating point to int conversion...
      T_X=$(echo "($(echo "${T_Y}/${DISP_Y}*${DISP_X}" | bc -l) +0.5/1" | bc)
    # do not do anything if the ratio is already correct
    elif (( $(echo "${DISP_RATIO}>${T_RATIO}" | bc -l) )); then 
      echo "Tablet X/Y ratio is smaller than screen's"
      T_Y=$(echo "($(echo "${DISP_Y}/${DISP_X} * ${T_X}" | bc -l) +0.5)/1" | bc)
      echo ${T_Y}
    else
      echo -e "The Tablet's X/Y ratio is the same as the display's.\nNothing to be done here. Exiting."  
    fi  

    STR_ROT="clockwise rotation by "
    # checking for rotation
    case $ROTATE in
      "90")  ROT="cw"    ; echo "Not implemented correctly" ;; # X1=0      Y1=$T_Y   X2=$T_X   Y2=0  ;echo "${STR_ROT} 90 degree";;
      "180") ROT="half"   X1=$T_X   Y1=$T_Y   X2=0      Y2=0  ;echo "${STR_ROT} 180 degree";;
      "270") ROT="ccw"   ;echo "Not implemented correctly" ;; # X1=$T_X   Y1=0      X2=0      Y2=$T_Y ;echo "${STR_ROT} 270 degree";;
      *)     ROT="none"   X1=0      Y1=0      X2=$T_X   Y2=$T_Y ;echo "No rotation is performed";;
    esac
    xsetwacom --set $ID_STYLUS Rotate $ROT

    # finally setting the tablet area
    # xsetwacom --set $ID_STYLUS Area 0 0 $T_X $T_Y
    xsetwacom --set $ID_STYLUS Area $X1 $Y1 $X2 $Y2

  fi  # display exists
fi # tablet exists

# source m708_button_config.sh
# source m708_button_config_okular_notes.sh
