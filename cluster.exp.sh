#!/bin/bash
# the main script having all the steps of experiment together

source cluster_properties.sh

./cluster_setup.sh up-full
gcloud compute copy-files ./install.sge.master.sh $MASTER_NODE_NAME_PATTERN:~/. --zone=$MASTER_NODE_ZONE
gcloud compute copy-files ./test.sh $MASTER_NODE_NAME_PATTERN:~/. --zone=$MASTER_NODE_ZONE
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
done

# log in to the master to do the test
gcloud compute ssh $MASTER_NODE_NAME_PATTERN --zone=$MASTER_NODE_ZONE
# log in to two workers to check the result
gcloud compute ssh $(worker_node_name 0) --zone=$WORKER_NODE_ZONE
gcloud compute ssh $(worker_node_name 1) --zone=$WORKER_NODE_ZONE

# for testing purpose, the clusters are destroyed right afterwards
#./cluster_setup.sh down-full
