#!/bin/bash
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"

script1="$SCRIPT_DIR""/mqtt_sensors.sh"
script2="$SCRIPT_DIR""/mqtt_callback.sh"

pid1=$(screen -ls mqttpub | grep "tached" | awk '{print$1}')
if [ "$pid1" == "" ]
then
    screen -dmS mqttpub "$script1" -v &
    echo "Publisher started"
else
    screen -X -S $pid1 quit
    screen -dmS mqttpub "$script1" -v &
    echo "Publisher restarted"
fi
pid1=$(screen -ls mqttsub | grep "tached" | awk '{print$1}')
if [ "$pid1" == "" ]
then
    screen -dmS mqttsub "$script2" -v &
    echo "Callback started"
else
    screen -X -S $pid1 quit
    screen -dmS mqttsub "$script2" -v &
    echo "Callback restarted"
fi