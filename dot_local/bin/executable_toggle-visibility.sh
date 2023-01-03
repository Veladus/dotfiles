#!/bin/bash

export NAME=$1
export CLASS=$2

function enable_rule() {
	bspc rule -a $1 state=floating sticky=on hidden=on private=on
}
function disable_rule() {
	bspc rule -r $1
}

# this process and grep use name, so look if there is at least one other process
# Also this process is counted twice
pidof $NAME
STARTED=$?

if [ "$STARTED" -ne "0" ]; then
	echo starting
	enable_rule $CLASS
	$NAME & sleep 0.2
fi

NODE_IDS=$(bspc query -N -n .leaf | xargs -i sh -c 'bspc query --node {} -T | grep -q $NAME && echo {}')

for NODE_ID in ${NODE_IDS[@]}; do
	bspc node $NODE_ID --flag hidden

	HIDDEN=$(bspc query -T -n $NODE_ID | jq '.hidden')
	if [ "$HIDDEN" == "true" ]; then
		enable_rule $CLASS
	else
		bspc node $NODE_ID -f
		disable_rule $CLASS
	fi
done
