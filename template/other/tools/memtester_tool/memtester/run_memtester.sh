#!/bin/bash -l
#SBATCH --exclusive -n 1 --output=/home/fcops/memtester/memtest.%j --mem=0

CORES=$(grep processor /proc/cpuinfo |wc -l)
MEM=$(free -m |grep ^Mem |awk '{print $2}')
MEM95PERC=$((MEM/100*80))
MEMPERCORE=$((MEM95PERC / CORES))

ulimit -l unlimited

#module load apps/memtester

i=1
while [ $i -le $CORES ] ; do
  /home/fcops/memtester/memtester $MEMPERCORE\M 10 > /tmp/memtest.out.$i 2>&1 &
   i=`expr $i + 1`
done

wait


