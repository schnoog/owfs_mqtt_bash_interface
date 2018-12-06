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


mosquitto_sub -R -h $_MQTTHOST -p $_MQTTPORT -u $_MQTTUSER -P $_MQTTPASS -q $_MQTTQOS -v -t "$MQTTCOMMANDTOPIC" | while read RAW_DATA
do
  echo "Got msg" 
 
	if [ "$(echo "$RAW_DATA" | grep -i "rescan 1" | wc -l)" == "1" ]
	then
		echo "Forcing rescan"
		echo "1" > "$RESCANTRIGGER"
	fi
 		






done







