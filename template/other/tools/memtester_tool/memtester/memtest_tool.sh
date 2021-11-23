#!/bin/bash

bash ~/memtester/bequiet.sh sudo bash ~/memtester/run_memtester.sh & sleep $1h

sudo killall -9 memtester

