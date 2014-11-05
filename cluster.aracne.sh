#!/bin/bash
# similar to cloud.aracne.sh, but using a SGE cluster instead of a  single instance

readonly PROJECT_ID=wise-mantra-567 # project name: geworkbench-Web
readonly INSTANCE_ZONE=us-central1-a

readonly ARACNE_SCRIPT=./aracne_submit.sh
readonly ARACNE_SOFTWARE_PACKAGE="./aracne2 ./usage.txt"
readonly EXPRESSION_DATA_FILE=./Bcell-100.exp
readonly HUBFILE=./hub.txt
readonly ARACNE_CONFIG_FILE=./config_threshold.txt

gcloud config set project $PROJECT_ID 

#gcloud compute instances create $INSTANCE_NAME --zone $INSTANCE_ZONE
#echo "instance $INSTANCE_NAME created at `date`"
#sleep 10 # if I start trying to copy files too soon, the connection will time out. But why? 

# the following section is copied from cluster.exp.sh
source cluster_properties.sh

./cluster_setup.sh up-full
gcloud compute copy-files ./install.sge.master.sh $MASTER_NODE_NAME_PATTERN:~/. --zone=$MASTER_NODE_ZONE
gcloud compute ssh $MASTER_NODE_NAME_PATTERN --zone=$MASTER_NODE_ZONE --command ./install.sge.master.sh
echo "done setting up the master: $MASTER_NODE_NAME_PATTERN"

# Worker node name formatter
function worker_node_name() {
  local instance_id="$1"
  printf $WORKER_NODE_NAME_PATTERN $instance_id
}
readonly -f worker_node_name

for ((i = 0; i < $WORKER_NODE_COUNT; i++)) do
  echo "Configuring worker node $(worker_node_name $i)"
  gcloud compute copy-files ./install.worker.sh $(worker_node_name $i):~/. --zone=$WORKER_NODE_ZONE
  gcloud compute ssh $(worker_node_name $i) --zone=$WORKER_NODE_ZONE --command ./install.worker.sh

  gcloud compute copy-files $ARACNE_SOFTWARE_PACKAGE $EXPRESSION_DATA_FILE $HUBFILE $ARACNE_CONFIG_FILE $(worker_node_name $i):~/. --zone $INSTANCE_ZONE
done

### end of section copied from cluster.exp.h

# to be cleaned-up/fixed later
readonly INSTANCE_NAME=$MASTER_NODE_NAME_PATTERN

echo start copying files `date`
# copy program files and data files
gcloud compute copy-files $ARACNE_SCRIPT $ARACNE_SOFTWARE_PACKAGE $EXPRESSION_DATA_FILE $HUBFILE $ARACNE_CONFIG_FILE $INSTANCE_NAME:~/. --zone $INSTANCE_ZONE
echo finished copying `date`

# run aracne
gcloud compute ssh $INSTANCE_NAME --zone $INSTANCE_ZONE --command "qsub ./aracne_submit.sh"

# check status
QSTAT_COUNT="-1"
while [ "$QSTAT_COUNT" -ne "0" ]
do
    sleep 30
    QSTAT_COUNT=$(gcloud compute ssh $INSTANCE_NAME --zone $INSTANCE_ZONE --command "qstat|wc -c")
    echo $QSTAT_COUNT
done

# copy the result back
rm -r -f results
mkdir results
#gcloud compute copy-files $INSTANCE_NAME:~/output.* $INSTANCE_NAME:~/*.adj $INSTANCE_NAME:~/adjfiles $INSTANCE_NAME:~/logs ./results --zone $INSTANCE_ZONE
for ((i = 0; i < $WORKER_NODE_COUNT; i++)) do
    gcloud compute copy-files $(worker_node_name $i):~/aracne.log $(worker_node_name $i):~/adjfiles $(worker_node_name $i):~/logs ./results --zone $INSTANCE_ZONE
done

# delete the VM instance
#gcloud compute instances delete $INSTANCE_NAME --zone $INSTANCE_ZONE -q

# check the results
ls -lt results/
