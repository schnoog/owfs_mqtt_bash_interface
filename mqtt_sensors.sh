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


#####################
declare -A MYDATA
declare -A CHANGENUM
#####################
###
###
#####################
echo "1" > "$RESCANTRIGGER"
echo "1" > "$RUNSCANFILE"
#####################
###
###
###

####################
###
###
####################

RUN=$(cat "$RUNSCANFILE")
RTIME=0



while [ "$RUN" == "1" ]
do




	TTIME=$(GetMT)
	let TX=RTIME+$SENSETIME
	sentCNT=0

	while [ $TX -gt $TTIME ]
	do
		let WT=$TX-$TTIME
		SLEEPTIME=$(echo "scale=2;"$WT"/1000" | bc -l)
		mlog "$SLEEPTIME seconds until next scan"

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
	RUN=$(cat "$RUNSCANFILE")
done




IFS=$MYIFS
