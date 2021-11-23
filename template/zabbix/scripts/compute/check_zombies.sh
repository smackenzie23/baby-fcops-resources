#!/bin/bash

ZOMBS=$(ps axo pid=,ppid=,state=,user= | grep Z 2> /dev/null)

COUNT=0

IFS=$'\n'; for ZOMBIE in $ZOMBS ; do

	ZPID=$(echo "$ZOMBIE" | awk '{print $1}')
	ZPPID=$(echo "$ZOMBIE" | awk '{print $2}')

	# Check process
	SLURMZ=$(scontrol pidinfo "$ZPID" 2> /dev/null)

	# Skip processes belonging to slurm
	if ! [ -z "$SLURMZ" ] ; then
		continue
	fi

	# Loop parents
	PARENT=$(echo "$ZPPID")

	while [ "$PARENT" -ne 1 ] ; do

		if [ -z "$PARENT" ] ; then
			continue 2
		fi

		SLURMP=$(scontrol pidinfo "$PARENT" 2>/dev/null)
		
		# Parent belongs to slurm
		if ! [ -z "$SLURMP" ] ; then
			continue 2
		fi

		PARENT=$(ps -o ppid -p "$PARENT" | grep -v "PPID" | xargs)
	done

	# Exhausted parents
	let "COUNT++"
done

echo $COUNT
