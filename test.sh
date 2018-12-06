#!/bin/bash

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
echo $SCRIPT_DIR

RESCANTRIGGER="/var/www/html/ramdisk/rescan4mqtt"
if [ ! -f $RESCANTRIGGER ]
then
echo "RST not available"

fi