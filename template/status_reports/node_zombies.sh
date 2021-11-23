#!/bin/bash

NODE=$1

ZOMBS=$(pdsh -w "$1" "ps axo pid=,ppid=,state=,user= | grep Z" 2>/dev/null)

echo -e "PROC\tPARENT\tSTATE\tUSER"

IFS=$'\n'; for ZOMBIE in $ZOMBS ; do

	ZPID=$(echo "$ZOMBIE" | awk '{print $2}')
	ZPPID=$(echo "$ZOMBIE" | awk '{print $3}')
	STATE=$(echo "$ZOMBIE" | awk '{print $4}')
	USER=$(echo "$ZOMBIE" | awk '{print $5}')

	# Check process
	SLURMZ=$(pdsh -w "$NODE" "scontrol pidinfo $ZPID" 2>/dev/null)

	# Skip processes belonging to slurm
	if ! [ -z "$SLURMZ" ] ; then
		continue
	fi

	# Loop parents
	PARENT=$(echo "$ZPPID")

	while [[ "$PARENT" != 1 ]] ; do

		if [ -z "$PARENT" ] ; then
			continue 2
		fi

		SLURMP=$(pdsh -w "$NODE" "scontrol pidinfo $PARENT" 2>/dev/null)

		# Parent belongs to slurm
		if ! [ -z "$SLURMP" ] ; then
			continue 2
		fi

		PARENT=$(pdsh -w $NODE "ps -o ppid -p $PARENT | grep -v PPID | xargs" | awk '{print $2}')
	done

	# Exhausted parents
	echo -e "$ZPID\t$ZPPID\t$STATE\t$USER"
done
