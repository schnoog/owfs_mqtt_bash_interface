#!/bin/bash

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
echo $SCRIPT_DIR

source settings.cfg
source functions.sh

#R8= 3A.8C3518000000 - B
#R7= 3A.8C3518000000 - A
#R6= 3A.D43518000000 - B



function GetLTI {
r8=$(owget 3A.8C3518000000/sensed.B)
r7=$(owget 3A.8C3518000000/sensed.A)
r6=$(owget 3A.D43518000000/sensed.B)
if [ "$r8" == "1" ]
then
    lvl=4
else
    if [ "$r7" == "1" ]
    then
        lvl=3
    else
        if [ "$r6" == "1" ]
        then
            lvl=2
        else
            lvl=1
        fi
    fi
fi 
echo $lvl
}



GetLTI
