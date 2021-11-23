#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SKIP_EXPECTED=true

if [ $# -gt 0 ]
then
        SKIP_EXPECTED=$1
fi

get_zone() {
	local I=$1
	sudo firewall-cmd --get-zone-of-interface $I 2>/dev/null
}

check_zone() {
	local Z=$1

	# Ports
        local P=$(sudo firewall-cmd --list-ports --zone=$Z)

	# Ports assigned via service
	for s in $(sudo firewall-cmd --list-services --zone=$Z); do
		P="$(sudo firewall-cmd --permanent --service $s --get-ports) $P"
	done

	echo "$P" | xargs
}

INTS=$(/usr/sbin/ifconfig 2> /dev/null | grep UP | awk '{print $1}'| cut -f1 -d ':')

DEFAULT_ZONE=$(sudo firewall-cmd --get-default-zone 2>/dev/null)
DEFAULT_PORTS=$(check_zone "$DEFAULT_ZONE")

OUTPUT=""

for INT in $INTS ; do

	# Skip virbr0
        if [[ ("$INT" == "virbr0") && ("$SKIP_EXPECTED" == "true") ]] ; then
                continue
        fi

	# Skip loopback
        if [[ ("$INT" == "lo") && ("$SKIP_EXPECTED" == "true") ]] ; then
                continue
        fi
	
	IP=$(/usr/sbin/ifconfig $INT 2> /dev/null | grep "inet " | awk '{print $2}')

	# Skip interfaces without an IP
        if [ -z $IP ] ; then
                continue
        fi

	# Skip Alces networks 10.10.X.X, 10.11.X.X, 10.12.X.X
        if [[ ("$IP" =~ (^10\.10\.)|(^10\.11\.)|(^10\.12\.)) && ("$SKIP_EXPECTED" == "true") ]] ; then
        	continue
        fi

        # Get firewall zone
	ZONE=$(get_zone "$INT")

	# Warn if in default zone
	if [ -z $ZONE ] ; then
		#echo -e "${YELLOW}$INT ($IP) - default zone $DEFAULT_ZONE ($DEFAULT_PORTS)${NC}"
		OUTPUT="${YELLOW}$INT ($IP) - default zone $DEFAULT_ZONE ($DEFAULT_PORTS)${NC}\n$OUTPUT"
	else
		# Check ports for this zone
		PORTS=$(check_zone "$ZONE")

		# Skip interfaces with no open ports
                if [ -z "$PORTS" ] ; then
                        continue
                fi

		# Colors
		if [[ "$ZONE" == "trusted" ]] ; then
			#echo -e "${GREEN}$INT ($IP) - $ZONE ($PORTS)${NC}"
			OUTPUT="${GREEN}$INT ($IP) - $ZONE ($PORTS)${NC}\n$OUTPUT"
		else
			#echo -e "${RED}$INT ($IP) - $ZONE ($PORTS)${NC}"
			OUTPUT="${RED}$INT ($IP) - $ZONE ($PORTS)${NC}\n$OUTPUT"
		fi
               	
	fi
done

echo -ne "$OUTPUT"

exit 0
