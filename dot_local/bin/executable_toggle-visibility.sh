#!/bin/bash

export NAME=$1

# this process and grep use name, so look if there is at least one other process
# Also this process is counted twice
[ "$(ps -x | grep -c $NAME)" -gt 3 ]
STARTED=$?
echo $STARTED $(ps -x | grep $NAME)

if [ "$STARTED" -ne "0" ]; then
	echo starting
	$NAME & sleep 0.2
fi

NODE_ID=$(bspc query -N -n .leaf | xargs -i sh -c 'bspc query --node {} -T | grep -q $NAME && echo {}')
if [ -z "$NODE_ID" ]; then
	exit
fi
bspc node $NODE_ID --flag hidden

HIDDEN=$(bspc query -T -n $NODE_ID | jq '.hidden')
if [ "$HIDDEN" == "false" ]; then
	bspc node $NODE_ID -f
fi
