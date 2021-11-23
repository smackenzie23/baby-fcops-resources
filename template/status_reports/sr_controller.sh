#!/bin/bash

# a script for the controller section of a daily check

d=$(date +%d)

RED='\033[0;31m'
NC='\033[0m'

export uptime=$(uptime) ;

echo -e "${RED}### uptime is:${NC}" ; echo '```'; echo "$uptime"; echo '```' ;

export memory=$(free -hm) ;

echo -e "${RED}### check controller memory:${NC}" ; echo '```'; echo "$memory"; echo '```' ;

export disk=$(df -h / /boot) ;

echo -e "${RED}### check controller disk space:${NC}" ; echo '```'; echo "$disk"; echo '```' ;
