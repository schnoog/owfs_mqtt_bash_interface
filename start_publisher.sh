#!/bin/bash
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"

script="$SCRIPT_DIR""/mqtt_sensors.sh"
screen -dmS mqttsensor "$script" -v &
