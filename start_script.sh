#!/bin/bash
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"

script="$SCRIPT_DIR""/mqtt_sensors.sh"
screen -dmS mqttpub "$script" -v &

script="$SCRIPT_DIR""/mqtt_callback.sh"
screen -dmS mqttsub "$script" -v &