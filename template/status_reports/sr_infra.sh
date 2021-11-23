#!/bin/bash

d=$(date +%d)

RED='\033[0;31m'
NC='\033[0m'

export uptime=$(pdsh -f1 -w infra1,infra2,infra3 uptime) ;

echo -e "${RED}### uptime is:${NC}" ; echo '```'; echo "$uptime"; echo '```' ;

export memory=$(pdsh -f1 -w infra1,infra2,infra3 free -hm) ;

echo -e "${RED}### check headnode memory/swap usage:${NC}" ; echo '```'; echo "$memory"; echo '```' ;
