#!/bin/bash
#$ -cwd -j y -o ./consensus.log

# here is the original 'template' I use
## #$ -l mem=6G,time=48:: -cwd -j y -o /ifs/data/c2b2/af_lab/cagrid/r/aracne/runs/ara30780/consensus.log -N ara30780
#Unable to run job: unknown resource "mem".

#export JOBNAME="ara30780"
#export BINDIR="/ifs/data/c2b2/af_lab/cagrid/r/aracne/bin/"
#export JOBDIR="/ifs/data/c2b2/af_lab/cagrid/r/aracne/runs/$JOBNAME"
#export LOGS="logs"
export ADJ="adjfiles"

cd "$JOBDIR"

#perl "$BINDIR"/getconsensusnet.pl "$ADJ" 1.0E-6
perl ./getconsensusnet.pl "$ADJ" 1.0E-6