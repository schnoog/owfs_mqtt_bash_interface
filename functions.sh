###
#####################
_V=0
while getopts "v" OPTION
do
  case $OPTION in
    v) _V=1
       ;;

  esac
done
###
function mlog () {
    if [[ $_V -eq 1 ]]; then
        echo "$@"
    fi
}
#####################
###
###

#####################
##
##
##
#####################

function GetMT {
	echo $(($(date +%s%N)/1000000))
}

#####################
##
##
##
#####################
#####################
function publish {
echo $1 | mosquitto_pub -h $_MQTTHOST -p $_MQTTPORT -u $_MQTTUSER -P $_MQTTPASS -q $_MQTTQOS -M 20 -t $2 -l
}

####################
###
###
####################
function FinalRound {
	tmp=$(expr index "$1" ".")
	if [ $tmp -eq 0 ]
	then
		echo $1
	else
		echo "scale=1; ("$1" * 10)/10" | bc -l
	fi
}

#####################
##
##
##
#####################
function GetRealValue {
	did=$1
	val=$2
	sid=${did:0:3}

	if [ "$sid" == "28." ]
	then

		erg=$( echo "$val > 70" | bc)
		if [ $erg == "1" ]
		then
			nv=$(echo "$val""*3.2+700" | bc)
			FinalRound $nv
		else
			FinalRound $val
		fi


	else
		FinalRound $val
	fi

}
#####################
##
##
##
#####################
function PublishDeviceList {
alldevs=$(find $OWFSMOUNTDIR -type d -maxdepth 1 -name '[2-9]*')
FDIR="$OWFSMOUNTDIR""/"
startlen=${#FDIR}
for dev in $alldevs
do
	DATA="unknown"
	if [ -f "$dev""/type" ]
	then
		DATA=$(cat "$dev""/type")
	fi
	devi=${dev:startlen}
	strOut="$MQTTMAINTOPIC""/Devices/$DATA"

	publish "$devi" "$strOut"
done
}
#####################
##
##
##
#####################

function PublishSingleDevice {
		device="$OWFSMOUNTDIR""/""$1"
		items=$(find "$device" -type f | grep -E "temperature|humidity|sensed.A|sensed.B" | grep -v -E "temperature9|temperature10|temperature11|temperature12|TAI8570|HIH|HTM")
	for mfile in $items
	do
		FDIR="$OWFSMOUNTDIR""/"
		startlen=${#FDIR}
		mid=${mfile:startlen}
		
		id=$(echo "$mid" | sed 's/\//_/g')
		TMPDATA=$(cat "$mfile")
		DATA=$(GetRealValue "$mid" "$TMPDATA")
			strOut="$MQTTMAINTOPIC""/Sensors/$mid"
			tmp=$(expr index "$DATA" ".")
			if [ "$tmp" != "0" ]
			then

				CFH=$(echo "$DATA > 700" | bc)
				if [ "$CFH" == "1" ]
				then
					strOutX=$(echo "$strOut" | sed 's/temperature/pressure/g')
					strOut=$strOutX
				fi
			fi

			publish "$DATA" "$strOut"

	done
}
#####################
##
##
##
#####################
#####################
##
##
##
#####################