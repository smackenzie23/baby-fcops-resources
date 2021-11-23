#!/bin/bash

d=$(date +%d)

RED='\033[0;31m'
NC='\033[0m'

export uptime=$(pdsh -f1 -g login uptime) ;

echo -e "${RED}### uptime is:${NC}" ; echo '```'; echo "$uptime"; echo '```' ;

export tmp=$(pdsh -f1 -w login1,login2 df -h /tmp) ;

echo -e "${RED}### check tmp partition space available on logins:${NC}" ; echo '```'; echo "$tmp"; echo '```' ;

export tmpviz=$(pdsh -f1 -g viz df -h /tmp) ;

echo -e "${RED}### check tmp partition space available on vis nodes:${NC}" ; echo '```'; echo "$tmpviz"; echo '```' ;

export disk=$(pdsh -f1 -g login df -h | grep -i root) ;

echo -e "${RED}### check disk space on logins${NC}" ; echo '```'; echo "$disk"; echo '```' ;

export memory=$(pdsh -f1 -g login free -hm) ;

echo -e "${RED}### check login memory/swap usage${NC}" ; echo '```'; echo "$memory"; echo '```' ;

export var=$(pdsh -f1 -g login df -h /var) ;

echo -e "${RED}### check var partition space:${NC}" ; echo '```'; echo "$var"; echo '```' ;

export ipmi=$(pdsh -f1 -g viz sudo ipmitool -c sel elist) ;

echo -e "${RED}### check sel logs:${NC}" ; echo '```'; echo "$ipmi"; echo '```'
