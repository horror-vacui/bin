#!/bin/bash
# toggles touchpad. Tested on Linux Mint 18.3 on MATE.

#MY_TOUCHPAD_ID = 14
MY_TOUCHPAD_ID=$(xinput | grep -i "touch" | sed "s/.*id=\([0-9]\+\).*/\1/")

a=$(xinput --list-props 14 | grep "Device Enabled" | cut -f 2 -d ":" | sed "s/[^0-9]*//g")

# Safety: if the value is different from 0 or 1, then the touchpad will be enabled. 
if [[ $a != 1 ]]; 
	then xinput --enable $MY_TOUCHPAD_ID;
	else xinput --disable $MY_TOUCHPAD_ID;
fi;

