#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${RED}## THIS STATUS REPORT WAS GENERATED ON:${NC}"

date

echo -e "${GREEN}## ~~~ CONTROLLER ~~~${NC}"

bash /users/fcops/status_reports/sr_controller.sh ;

echo "----"
echo -e "${GREEN}## ~~~ MASTER ~~~${NC}"

bash /users/fcops/status_reports/sr_master.sh ;

echo "----"
echo -e "${GREEN}## ~~~ STORAGE ~~~${NC}"

bash /users/fcops/status_reports/sr_storage.sh ;

echo "----"
echo -e "${GREEN}## ~~~ INFRA ~~~${NC}"

bash /users/fcops/status_reports/sr_infra.sh ;

echo "----"
echo -e "${GREEN}## ~~~ LOGIN ~~~${NC}"

bash /users/fcops/status_reports/sr_login.sh ;

echo "----"
echo -e "${GREEN}## ~~~ COMPUTE ~~~${NC}"

bash /users/fcops/status_reports/sr_compute.sh ;

echo "----"
echo -e "${GREEN}## ~~~ SECURITY ~~~${NC}"

bash /users/fcops/status_reports/sr_security.sh ;
