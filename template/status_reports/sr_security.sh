#!/bin/bash

d=$(date +%d)

RED='\033[0;31m'
NC='\033[0m'

# Collate last 24 hours of /var/log/secure
#pdsh -g all "DFTMP=\$(date --date=\"09:00 1 day ago\" \"+%b %_d %H\"); DTTMP=\$(date \"+%b %_d %H:%M:%S\"); sudo sed -n \"/^\${DFTMP}/,/^\${DTTMP}/ p\" /var/log/secure | grep 'sshd'" > /tmp/secure.log 2>/dev/null
pdsh -g all "DFTMP=\$(date --date=\"09:00 1 day ago\" \"+%b %_d %H:%M:%S\"); sudo cat /var/log/secure | awk '\$0 >= \"${DFTMP}\"' | grep 'sshd'" > /tmp/secure.log 2>/dev/null


# Login summary
echo -e "${RED}### external login summary:${NC}" ;
echo '```';
#echo "total successful: $(cat /tmp/secure.log | grep -i 'accepted' | awk '{if ($12 !~ /^10[.]10[.]|^10[.]11[.]|^10[.]12[.]|^127[.]0[.]0[.]1/) print $0}' | wc -l)"
#echo "unique ips: $(cat /tmp/secure.log | grep -i 'accepted' | awk '{print $12}' | egrep -v '^10[.]10[.]|^10[.]11[.]|^10[.]12[.]|^127[.]0[.]0[.]1' | sort | uniq | wc -l)"
echo "password logins: $(cat /tmp/secure.log | egrep -i 'accepted password|accepted keyboard-interactive/pam' | awk '{if ($12 !~ /^10[.]10[.]|^10[.]11[.]|^10[.]12[.]|^127[.]0[.]0[.]1/) print $0}' | wc -l)"
echo "key logins: $(cat /tmp/secure.log | grep -i 'accepted publickey' | awk '{if ($12 !~ /^10[.]10[.]|^10[.]11[.]|^10[.]12[.]|^127[.]0[.]0[.]1/) print $0}' | wc -l)"
echo "failed passwords: $(cat /tmp/secure.log | grep -i 'failed password' | awk '{ if ($10 == "invalid") { ip=$14 } else { ip=$12 } if (ip !~ /^10[.]10[.]|^10[.]11[.]|^10[.]12[.]|^127[.]0[.]0[.]1/) { print $0 } }' | wc -l)"
echo "failed ips: $(cat /tmp/secure.log | grep -i 'failed password' | awk '{ if ($10 == "invalid") { ip=$14 } else { ip=$12 } if (ip !~ /^10[.]10[.]|^10[.]11[.]|^10[.]12[.]|^127[.]0[.]0[.]1/) { print ip } }' | sort | uniq | wc -l)"
echo '```' ;

# Login check non-public
warn_nodes=$(cat /tmp/secure.log | grep -i "accepted" | awk '{ if ($12 !~ /^10[.]10[.]|^10[.]11[.]|^10[.]12[.]|^127[.]0[.]0[.]1/) { print $1 } }' | sort | uniq | while IFS= read -r node ; do node=$(echo "$node" | sed 's/://') ; if [[ -z $(nodeattr -l "$node" | grep "publicfacing") ]] ; then echo "$node" ; fi ; done ;)
if [[ -z $warn_nodes ]] ; then warn_nodes="Check complete." ; fi ;

echo -e "${RED}### external logins on internal nodes:${NC}" ; echo '```'; echo "$warn_nodes"; echo '```' ;

# Failed login check - users
failed_logins=$(cat /tmp/secure.log | grep -i "failed password" | awk '{ if ($10 == "invalid") { ip=$14 ; user=$12 } else { ip=$12 ; user=$10 } if (ip !~ /^10[.]10[.]|^10[.]11[.]|^10[.]12[.]|^127[.]0[.]0[.]1/) { print user } }' | sort | uniq -c | sort -nr)
if [[ -z $failed_logins ]] ; then failed_logins="No failed login attempts" ; fi ;

echo -e "${RED}### failed user login attempts:${NC}" ; echo '```'; echo "$failed_logins"; echo '```' ;

# Failed login check - ips
failed_logins_ips=$(cat /tmp/secure.log | grep -i "failed password" | awk '{ if ($10 == "invalid") { ip=$14 ; user=$12 } else { ip=$12 ; user=$10 } if (ip !~ /^10[.]10[.]|^10[.]11[.]|^10[.]12[.]|^127[.]0[.]0[.]1/) { print ip } }' | sort | uniq -c | sort -nr)
if [[ -z $failed_logins_ips ]] ; then failed_logins_ips="No failed login attempts" ; fi ;

echo -e "${RED}### failed login ips:${NC}" ; echo '```'; echo "$failed_logins_ips"; echo '```' ;

# Successful login check
successful_logins=$(cat /tmp/secure.log | grep -i "accepted" | awk '{print $12}' | egrep -v '^10[.]10[.]|^10[.]11[.]|^10[.]12[.]|^127[.]0[.]0[.]1' | sort | uniq -c)
if [[ -z $successful_logins ]] ; then successful_logins="No successful logins" ; fi ;

# Flag new external login IPs
new_ips=$(echo "$successful_logins" | awk '{if ($2 != "successful") { print $2 } }' | while IFS= read -r ip ; do known=$(cat /users/fcops/status_reports/ips.log | grep "$ip"); if [[ -z "$known" ]] ; then echo "$ip" | sudo tee -a /users/fcops/status_reports/ips.log ; fi ; done)
if [[ -z $new_ips ]] ; then new_ips="No new external IPs" ; fi ;

echo -e "${RED}### external logins - new IPs:${NC}" ; echo '```'; echo "$new_ips"; echo '```' ;

#echo -e "${RED}### successful external logins:${NC}" ; echo '```'; echo "$successful_logins"; echo '```' ;
