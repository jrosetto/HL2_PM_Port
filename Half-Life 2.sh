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

# Install half life binaries / config files
if [[ -f "${GAMEDIR}/engine.zip" ]]; then
    if [[ ! -f "${GAMEDIR}/hl2/hl2_pak_000.vpk" ]]; then
        echo "Missing game files, see README for more info." > "$CUR_TTY"
        sleep 5
        printf "\033c" > "$CUR_TTY"
        $ESUDO systemctl restart oga_events &
        exit 1
    fi

    echo "Extracting engine." > "$CUR_TTY"

    $ESUDO unzip "${GAMEDIR}/engine.zip" | $ESUDO tee -a ./log.txt

    # Mark step as done
    $ESUDO rm -fv "${GAMEDIR}/engine.zip" | $ESUDO tee -a ./log.txt
fi

export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"

if [[ $CFW_NAME == "muOS" ]]; then
  export LD_PRELOAD="${GAMEDIR}/lib/libSDL2-2.0.so.0.2800.5:${LD_PRELOAD}"
fi

$GPTOKEYB "hl2_launcher.gptk" &
$TASKSET ./hl2_launcher -gamepadui -fullscreen -normal -w 640 -h 480 2>&1 | tee -a ./log.txt

$ESUDO kill -9 $(pidof gptokeyb)
unset SDL_GAMECONTROLLERCONFIG
$ESUDO systemctl restart oga_events &

# Disable console
printf "\033c" >> "$CUR_TTY"