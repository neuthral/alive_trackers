#!/bin/env bash

##
# Loop through list of trackers and test if they are alive using nc
# nc -v -z -w 3 -u "$host" "$port"
##

usage () {
    printf '\n%s\n' "Loop through list of trackers and test if they are alive using nc"
	printf '\n' "and save alive trackers to alive.txt"
	printf '\n%s\n\n' "Usage: $(basename "$0") [list-of-trackers.file]"
	exit
}

if [[ ! -f $1 ]]; then
	usage
fi


while read -r LINE; do
	# split whole URI into parts
    FIELDS=($(echo "$LINE" | grep -o "[a-z0-9.-]*" | tr "\n" ' '))

	if [[ ${FIELDS[0]} == "udp" ]]; then
		# set udp flag if protocol is udp
		ARGS="-z -v -w 10 -u"
	else
		ARGS="-z -v -w 10"
	fi

	if [[ ! ${FIELDS[1]} ]]; then
		 echo '-'
	else
		# check if port field is a number else assing it 80
		RE='^[0-9]+$'
		if ! [[ ${FIELDS[2]} =~ $RE ]] ; then
			FIELDS[2]=80
		fi
		if nc $(echo "$ARGS ${FIELDS[1]} ${FIELDS[2]}"); then
		    echo -e "$LINE\n" >> alive.txt
		fi
	fi
done < "$1"

