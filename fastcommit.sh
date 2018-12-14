#!/bin/bash

tmp="fast commit"
if [ "$1" != "" ]
then
tmp="$@"
fi

git add . && git commit -m "$tmp" && git push
