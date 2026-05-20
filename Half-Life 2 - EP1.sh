#!/bin/bash
# PORTMASTER: half-life2.zip, Half-Life 2.sh

XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}

if [ -d "/opt/system/Tools/PortMaster/" ]; then
  controlfolder="/opt/system/Tools/PortMaster"
elif [ -d "/opt/tools/PortMaster/" ]; then
  controlfolder="/opt/tools/PortMaster"
elif [ -d "$XDG_DATA_HOME/PortMaster/" ]; then
  controlfolder="$XDG_DATA_HOME/PortMaster"
else
  controlfolder="/roms/ports/PortMaster"
fi

# Source control.txt and tasksetter from PortMaster
source $controlfolder/control.txt
source $controlfolder/tasksetter
source $controlfolder/device_info.txt

# Function to get controls from control.txt
get_controls

CUR_TTY=/dev/tty0
PORTDIR="/$directory/ports/"
GAMEDIR="${PORTDIR}/halflife2"

# Change directory to the game directory
cd "$GAMEDIR"

# Grab text output...
$ESUDO chmod 666 "$CUR_TTY"
$ESUDO touch log.txt
$ESUDO chmod 666 log.txt
$ESUDO chmod 666 /dev/uinput
export TERM=linux
printf "\033c" > "$CUR_TTY"

export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

> "${GAMEDIR}/ep1log.txt"
$GPTOKEYB "hl2_launcher" &
$TASKSET ./hl2_launcher -gamepadui -game episodic -fullscreen -high 2>&1 | tee -a "${GAMEDIR}/ep1log.txt"

$ESUDO kill -9 $(pidof gptokeyb)
unset SDL_GAMECONTROLLERCONFIG
$ESUDO systemctl restart oga_events &

# Disable console
printf "\033c" >> "$CUR_TTY"