# Bash functions to make window active or open applications
# - firefox
# - thunderbird
# - anki
# - KeePassXC
# - toggle
#
# Not the most elegent, because xdotools are invoked twice, 
# but it has little performance penalty, and it works.

function search_open_firefox {
  xdotool search "Mozilla Firefox" 
  if [ $? -eq 0 ]; then
    xdotool search "Mozilla Firefox" windowactivate 
  else
    firefox  
  fi  
}

function search_open_anki {
  xdotool search "Anki" 
  if [ $? -eq 0 ]; then
    xdotool search "Anki" windowactivate 
  else
    anki
  fi  
}

function search_open_thunderbird {
  xdotool search "Thunderbird" 
  if [ $? -eq 0 ]; then
    xdotool search "Thunderbird" windowactivate 
  else
    thunderbird
  fi  
}

function search_open_keepass {
  xdotool search "KeePassXC" 
  if [ $? -eq 0 ]; then
    xdotool search "KeePassXC" windowactivate 
  else
   keepassxc
  fi  
}

function search_open_toggl {
  xdotool search "Toggl Desktop" 
  if [ $? -eq 0 ]; then
    xdotool search "Toggl Desktop" windowactivate 
  else
   /usr/local/toggl/TogglDesktop.sh 
  fi  
}
