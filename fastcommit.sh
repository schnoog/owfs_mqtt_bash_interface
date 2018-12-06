#!/bin/bash

tmp="fast commit"
if [ "$@" != "" ]
then
tmp="$@"
fi

git add . && git commit -m "$tmp" && git push
