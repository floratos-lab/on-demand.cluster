#!/bin/bash
#$ -l mem=6G,time=48:: -t 1-100 -cwd -j y -o ./aracne.log -N ara30780

# these two are meant to be generated from SGE cluster
export SGE_TASK_ID="1"
export JOB_NAME="ara30780"

export INFILE="Bcell-100.exp"
export HUBFILE="hub.txt"
export BINDIR=.
export JOBDIR=.
export LOGS="logs"
export ADJ="adjfiles"

mkdir $LOGS
mkdir $ADJ

"$BINDIR"/aracne2 -i "$INFILE" -a Adaptive_Partitioning -r "$SGE_TASK_ID" -e 0.0 -p 7.9683815E-10 -H "$JOBDIR"  -s "$HUBFILE" -l "$HUBFILE" -o "$ADJ/$INFILE"_r"$SGE_TASK_ID".adj >& "$LOGS/$JOB_NAME"_"$SGE_TASK_ID".out