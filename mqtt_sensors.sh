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
#####################
#
#
#
#####################
declare -A MYDATA
declare -A CHANGENUM
#####################
###
###
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
echo "1" > "$RESCANTRIGGER"
#####################
###
###
###
#####################
function publish {
echo $1 | mosquitto_pub -h $_MQTTHOST -p $_MQTTPORT -u $_MQTTUSER -P $_MQTTPASS -q $_MQTTQOS -t $2 -l
}

#####################
##
##
##
#####################


function GetMT {
	echo $(($(date +%s%N)/1000000))
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
####################
###
###
####################

RUN=1
RTIME=0



while [ $RUN -eq 1 ]
do


	TTIME=$(GetMT)
	let TX=RTIME+$SENSETIME
	sentCNT=0


		let WT=$TX-$TTIME
		SLEEPTIME=$(echo "scale=2;"$WT"/1000" | bc -l)
		mlog "Sleep for $SLEEPTIME seconds"

	while [ $TX -gt $TTIME ]
	do
		let WT=$TX-$TTIME
		SLEEPTIME=$(echo "scale=2;"$WT"/1000" | bc -l)
		mlog "Sleep for $SLEEPTIME seconds"

		RESCAN=$(cat "$RESCANTRIGGER")
		if [ "$RESCAN" == "1" ]
		then
			TX=0
		else
			sleep 0.5
			TTIME=$(GetMT)
		fi
	done




	RESCAN=$(cat "$RESCANTRIGGER")
	echo "0" > "$RESCANTRIGGER"
	if [ "$RESCAN" == "1" ]
	then
		allfiles=$(find $OWFSMOUNTDIR/[2-9]* -type f | grep -E "temperature|humidity|sensed.A|sensed.B" | grep -v -E "temperature9|temperature10|temperature11|temperature12|TAI8570|HIH|HTM")
		ic=0
		for itemA in $allfiles
			do
			let ic=$ic+1
		done
	mlog "Scanner found $ic items"
	RTIME=0
	fi





	for mfile in $allfiles
	do

		mid=${mfile:11}
		id=$(echo "$mid" | sed 's/\//_/g')
		TMPDATA=$(cat "$mfile")
		DATA=$(GetRealValue "$id" "$TMPDATA")
		if [ "$RESCAN" == "1" ]
		then
			MYDATA[$id]="rescan"
		fi			

		if [ "$DATA" != "${MYDATA[$id]}" ]
		then
			oldval="${MYDATA[$id]}"
			MYDATA[$id]=$DATA

			let CHANGENUM[$id]=${CHANGENUM[$id]}+1

			let sentCNT=$sentCNT+1
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

			if [ ${CHANGENUM[$id]} -gt 0 ]
			then 
				mlog "NewValue for $strOut ---- $DATA  :::: CHANGED:"${CHANGENUM[$id]}" times old value: $oldval"
			fi

			publish "$DATA" "$strOut"

		fi
	done


	mlog "Sent $sentCNT items"

	RTIME=$TTIME

done




IFS=$MYIFS
