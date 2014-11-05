#!/bin/bash
# request Bourne shell as shell for job
#$ -S /bin/sh
#$ -t 1-100 -cwd -j y -o ./aracne.log

# take this out for now in case it causes problem
# -N ara30780

# these to parameters cause error, so I took them out for now
# -l mem=6G,time=48::

# these two are meant to be generated from SGE cluster
#export SGE_TASK_ID="1"
#export JOB_NAME="ara30780"

readonly INFILE="Bcell-100.exp"
readonly HUBFILE="hub.txt"
readonly BINDIR=.
readonly JOBDIR=.
readonly LOGS="logs"
readonly ADJ="adjfiles"

mkdir -p $LOGS
mkdir -p $ADJ

"$BINDIR"/aracne2 -i "$INFILE" -a Adaptive_Partitioning -r "$SGE_TASK_ID" -e 0.0 -p 7.9683815E-10 -H "$JOBDIR"  -s "$HUBFILE" -l "$HUBFILE" -o "$ADJ/$INFILE"_r"$SGE_TASK_ID".adj > "$LOGS/$JOB_NAME"_"$SGE_TASK_ID".out 2>&1
