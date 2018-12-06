#!/bin/bash
MYIFS=$IFS
IFS="
"

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
#####################
####
#### SETTINGS
####	source settings.cfg
####
#####################
SETTINGSFILE="$SCRIPT_DIR""/settings.cfg"
source "$SETTINGSFILE"