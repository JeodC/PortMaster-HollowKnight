#!/bin/bash

if [ -d "/opt/system/Tools/PortMaster/" ]; then
  controlfolder="/opt/system/Tools/PortMaster"
elif [ -d "/opt/tools/PortMaster/" ]; then
  controlfolder="/opt/tools/PortMaster"
else
  controlfolder="/roms/ports/PortMaster"
fi

source $controlfolder/control.txt
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"
get_controls

# Variables
GAMEDIR=/$directory/ports/hollow_knight

# CD and set permissions
cd $GAMEDIR
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1
$ESUDO chmod +x -R $GAMEDIR/*

# Display loading splash
[ "$CFW_NAME" == "muOS" ] && $ESUDO $GAMEDIR/splash "splash.png" 1
$ESUDO $GAMEDIR/splash "splash.png" 80000 & 

# Exports
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export WINEPREFIX=~/.wine64
export WINEDEBUG=-all

# Install dependencies
if ! winetricks list-installed | grep -q "^dxvk$"; then
    pm_message "Installing dependencies."
    winetricks dxvk
fi

# Config Setup
mkdir -p $GAMEDIR/config
bind_directories "$WINEPREFIX/drive_c/users/root/AppData/LocalLow/Team Cherry/Hollow Knight" "$GAMEDIR/config"

# Run the game
$GPTOKEYB "hollow_knight.exe" -c "./hollow.gptk" &
box64 wine64 "./data/hollow_knight.exe"

# Kill processes
wineserver -k
pm_finish