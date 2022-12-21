#!/bin/bash

export NAME=$1

# this process and grep use name, so look if there is at least one other process
# Also this process is counted twice
pidof $NAME
STARTED=$?

if [ "$STARTED" -ne "0" ]; then
	echo starting
	$NAME & sleep 0.2
fi

NODE_IDS=$(bspc query -N -n .leaf | xargs -i sh -c 'bspc query --node {} -T | grep -q $NAME && echo {}')

for NODE_ID in ${NODE_IDS[@]}; do
	bspc node $NODE_ID --flag hidden

	HIDDEN=$(bspc query -T -n $NODE_ID | jq '.hidden')
	if [ "$HIDDEN" == "false" ]; then
		bspc node $NODE_ID -f
	fi
done
