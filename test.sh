#!/bin/bash

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
echo $SCRIPT_DIR

source settings.cfg
source functions.sh

PublishSingleDevice "26.33D984000003"
