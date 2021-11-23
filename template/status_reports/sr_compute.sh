#!/bin/bash

RED='\033[0;31m'
NC='\033[0m'

export powerstatus=$(ssh root@controller "metal power -g cn status") ;

echo -e "${RED}### check power status${NC}" ; echo '```'; echo "$powerstatus"; echo '```' ;

export iblink=$(pdsh -f1 -g compute "sudo ibstatus | grep -i 'state\|rate'" ) ;

echo -e "${RED}### check ib link status${NC}" ; echo '```'; echo "$iblink"; echo '```' ;

export disk=$(pdsh -f1 -g compute df -h / /tmp /var | grep -v "Filesystem Use") ;

echo -e "${RED}### check compute local disk space${NC}" ; echo '```'; echo "$disk"; echo '```' ;

export memory=$(swapcheck=$(pdsh -g compute -x viz0[1-2] free -m | awk '/Swap/ {if ($3 == 0) {} else if ($4/$3 >= 0.8) {print $1 " above 80% swap: " $4 "MB out of " $3 "MB"}}' | sort -nk1) ; if [ -z "$swapcheck" ] ; then echo "The nodes are fine" ; else echo "$swapcheck" ; fi ;) ;

echo -e "${RED}### check compute swap usage${NC}" ; echo '```'; echo "$memory"; echo '```' ;

export reboots=$(pdsh -f1 -g compute uptime) ;

echo -e "${RED}### check for reboots${NC}" ; echo '```'; echo "$reboots"; echo '```' ;

export ipmi=$(pdsh -f1 -g compute 'sudo ipmitool sel list') ;

echo -e "${RED}### check compute ipmi for any messages${NC}" ; echo '```'; echo "$ipmi"; echo '```' ;

export zombie=$(bash /users/fcops/status_reports/check_zombie.sh) ;

echo -e "${RED}### check for zombies${NC}" ;

if [ -z "$zombie" ]

then

    echo '```'; echo "Check Complete"; echo '```';

else

    echo '```'; echo "$zombie"; echo '```' ;

fi
