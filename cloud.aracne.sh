# this script starts the task from the client side, i.e. cygwin terminal
# it automates the process of running an aracne job on the dynamically created standard instance of google cloud compute engine
# in the other words, no persistence disk is created or maintained for this task

readonly PROJECT_ID=wise-mantra-567 # project name: geworkbench-Web
readonly INSTANCE_ZONE=us-central1-a
readonly INSTANCE_NAME=zj-test-instance

readonly ARACNE_SCRIPT=./aracne_submit.sh
readonly ARACNE_SOFTWARE_PACKAGE="./aracne2 ./usage.txt"
readonly EXPRESSION_DATA_FILE=./Bcell-100.exp
readonly HUBFILE=./hub.txt
readonly ARACNE_CONFIG_FILE=./config_threshold.txt

gcloud config set project $PROJECT_ID 
gcloud compute instances create $INSTANCE_NAME --zone $INSTANCE_ZONE
echo "instance $INSTANCE_NAME created at `date`"
sleep 10 # if I start trying to copy files too soon, the connection will time out. But why? 

echo start copying files`date`
# copy program files and data files
gcloud compute copy-files $ARACNE_SCRIPT $ARACNE_SOFTWARE_PACKAGE $EXPRESSION_DATA_FILE $HUBFILE $ARACNE_CONFIG_FILE $INSTANCE_NAME:~/. --zone $INSTANCE_ZONE
echo finished copying `date`

# run aracne
gcloud compute ssh $INSTANCE_NAME --zone $INSTANCE_ZONE --command $ARACNE_SCRIPT

# copy the result back
rm -r -f results
mkdir results
gcloud compute copy-files $INSTANCE_NAME:~/output.* $INSTANCE_NAME:~/*.adj $INSTANCE_NAME:~/adjfiles $INSTANCE_NAME:~/logs ./results --zone $INSTANCE_ZONE

# delete the VM instance
gcloud compute instances delete $INSTANCE_NAME --zone $INSTANCE_ZONE -q

# check the results
ls -lt results/
