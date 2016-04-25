#!/bin/bash

nthreads=$1
nhands=$2

for i in `seq 1 $nthreads`
do
    ./generate.py data/ponds$i.csv $nhands &
done
