#!/bin/bash
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"

pid1=$(screen -ls mqttpub | grep "tached" | awk '{print$1}')
if [ "$pid1" == "" ]
then
    echo "Publisher not running"
else
    screen -X -S $pid1 quit
    echo "Publisher killed"
fi
pid1=$(screen -ls mqttsub | grep "tached" | awk '{print$1}')
if [ "$pid1" == "" ]
then
    echo "Callback not running"
else
    screen -X -S $pid1 quit
    echo "Callback killed"
fi
