#!/bin/bash

d=$(date +%d)

RED='\033[0;31m'
NC='\033[0m'

# Check firewalls - TODO: handle port forwarding?
check_interfaces=$(pdsh -g all -X nodes 'curl -s http://fcgateway/resources/status_reports/check_interfaces.sh | bash' 2>/dev/null)

echo -e "${RED}### firewall zones:${NC}" ; echo '```'; echo "$check_interfaces" ; echo '```' ;

# Todo: check inactive users

# Check gender used for security checks
check_gender=$(for n in $(echo "$check_interfaces" | grep "external" | awk '{print $1}' | uniq | tr -d ':') ; do if [ -z $(nodeattr -l "$n" | grep publicfacing) ] ; then echo "$n not in publicfacing gender" ; fi ; done)
if [[ -z $check_gender ]] ; then check_gender="Check complete." ; fi ;

echo -e "${RED}### security gender issues:${NC}"; echo '```'; echo "$check_gender"; echo '```' ;

# List external login ips
echo -e "${RED}### list external login ips:${NC}" ; echo '```'; cat /users/fcops/status_reports/ips.log | sort ; echo '```' ;
