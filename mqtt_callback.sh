#!/bin/bash
MYIFS=$IFS
IFS="
"


#####################################################################
####															#####
#### SETTINGS													#####
####	source settings.cfg										#####
####															#####
#####################################################################
source "$(dirname "$(readlink -f "$0")")""/settings.cfg"
#####################################################################
####															#####
#### FUNCTIONS													#####
####	include functions.sh									#####
####															#####
#####################################################################
source "$(dirname "$(readlink -f "$0")")""/functions.sh"
#####################################################################
#####################################################################

#####################################################################################################################################
########
########
#####################################################################################################################################
mosquitto_sub -R -h $_MQTTHOST -p $_MQTTPORT -u $_MQTTUSER -P $_MQTTPASS -q $_MQTTQOS -v -t "$MQTTCOMMANDTOPIC" | while read RAW_DATA
do
  echo "Got msg" 
 
	msg="rescan 1"
	if [ "$(echo "$RAW_DATA" | grep -i "$msg" | wc -l)" == "1" ]
	then
		echo "Forcing rescan"
		echo "1" > "$RESCANTRIGGER"
	fi
 	msg="getdevice"	
	if [ "$(echo "$RAW_DATA" | grep -i "$msg" | wc -l)" == "1" ]
	then
		device=$(echo $RAW_DATA | awk '{print $2}' |  grep -P '^[0-9a-fA-F]{2}\.[0-9a-fA-F]{12}$' )
		if [ $device != "" ]
		then
			PublishSingleDevice "$device"
			echo "Single Device Scan"
		fi
	fi
 	msg="devices"	
	if [ "$(echo "$RAW_DATA" | grep -i "$msg" | wc -l)" == "1" ]
	then
		PublishDeviceList
	fi





done
#####################################################################################################################################
########
########
#####################################################################################################################################







