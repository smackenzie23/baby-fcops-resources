#!/bin/bash

d=$(date +%d)

RED='\033[0;31m'
NC='\033[0m'

export uptime=$(pdsh -f1 -g storage uptime) ;

echo -e "${RED}### check storage uptime/reboots:${NC}" ; echo '```'; echo "$uptime"; echo '```' ;

export pfcapacity=$(pdsh -f1 -w login1 lfs df -h | grep -i file) ;

echo -e "${RED}### check parallel filesystem capacity:${NC}" ; echo '```'; echo "$pfcapacity"; echo '```' ;

export inodes=$(pdsh -f1 -w login1 lfs df -hi | grep -i file) ;

echo -e "${RED}### check parallel filesystem inodes:${NC}" ; echo '```'; echo "$inodes"; echo '```' ;

export users=$(pdsh -f1 -w login1 df -h /users) ;

echo -e "${RED}### check user filesystems:${NC}" ; echo '```'; echo "$users"; echo '```' ;

export gridware=$(pdsh -f1 -w login1 df -h /opt/gridware) ;

echo -e "${RED}### check user filesystems gridware:${NC}" ; echo '```'; echo "$gridware"; echo '```' ;

export service=$(pdsh -f1 -w login1 df -h /opt/service) ;

echo -e "${RED}### check user filesystems service:${NC}" ; echo '```'; echo "$service"; echo '```' ;

export apps=$(pdsh -f1 -w login1 df -h /opt/apps) ;

echo -e "${RED}### check user filesystems apps:${NC}" ; echo '```'; echo "$apps"; echo '```' ;

export disk=$(pdsh -f1 -g storage 'df -h / /tmp /var') ;

echo -e "${RED}### check disk space available:${NC}" ; echo '```'; echo "$disk"; echo '```' ;

export data1=$(pdsh -f1 -w login1 df -h /mnt/data1) ;

echo -e "${RED}### check volume data1:${NC}" ; echo '```'; echo "$data1"; echo '```' ;

export data2=$(pdsh -f1 -w login1 df -h /mnt/data2) ;

echo -e "${RED}### check volume data2:${NC}" ; echo '```'; echo "$data2"; echo '```' ;

export data3=$(pdsh -f1 -w login1 df -h /mnt/data3) ;

echo -e "${RED}### check volume data3:${NC}" ; echo '```'; echo "$data3"; echo '```' ;

export arrays=$(pdsh -f1 -g storage sudo '/opt/MegaRAID/MegaCli/MegaCli64 -ldinfo -lall -aall' | grep State) ;

echo -e "${RED}### check disk status in arrays:${NC}" ; echo '```'; echo "$arrays"; echo '```' ;

export quota=$(pdsh -f1 -w master2 sudo repquota -s /export/users | grep +) ;

echo -e "${RED}### check for users over quota:${NC}" ;

if [ -z "$quota" ]

then

    echo '```'; echo "Check Complete"; echo '```';

else

    echo '```'; echo "$quota"; echo '```' ;

fi
