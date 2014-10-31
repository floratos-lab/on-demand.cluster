#!/bin/bash
# the script to run aracne

export INFILE=./Bcell-100.exp
export HUBFILE=./hub.txt

./aracne2 -i "$INFILE" -a Adaptive_Partitioning -e 0.0 -p 1.9841269E-7 -H .  -s "$HUBFILE" -l "$HUBFILE" >> ./output.txt
