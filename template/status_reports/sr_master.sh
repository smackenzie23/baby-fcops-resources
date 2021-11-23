#!/bin/bash

# a script for the master section of a daily check

d=$(date +%d)

RED='\033[0;31m'
NC='\033[0m'

export ha=$(pdsh -f1 -g masters sudo crm_mon -1 | grep -i last) ;

echo -e "${RED}### check master HA pair status:${NC}" ; echo '```'; echo "$ha"; echo '```' ;

export disk=$(pdsh -f1 -g masters df -h | grep -i root) ;

echo -e "${RED}### check disk space (local):${NC}" ; echo '```'; echo "$disk"; echo '```' ;

export ipmi=$(pdsh -f1 -g masters sudo ipmitool -c sel elist) ;

echo -e "${RED}### check IPMI on masters:${NC}" ; echo '```'; echo "$ipmi"; echo '```' ;

export uptime=$(pdsh -f1 -g masters uptime) ;

echo -e "${RED}### uptime is:${NC}" ; echo '```'; echo "$uptime"; echo '```' ;

export backups=$(pdsh -f1 -g masters sudo /root/check_dirvish) ;

echo -e "${RED}### check backups complete:${NC}" ; echo '```'; echo "$backups"; echo '```' ;

export memory=$(pdsh -f1 -g masters free -hm) ;

echo -e "${RED}### check memory/swap usage:${NC}" ; echo '```'; echo "$memory"; echo '```' ;

