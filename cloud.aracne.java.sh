# this is based on and similar to the original cloud.aracne.sh but uses the new java implementation of aracne of 2015

# this script starts the task from the client side, i.e. cygwin terminal
# it automates the process of running an aracne job on the dynamically created standard instance of google cloud compute engine
# in the other words, no persistence disk is created or maintained for this task

readonly PROJECT_ID=wise-mantra-567 # project name: geworkbench-Web
readonly INSTANCE_ZONE=us-central1-a
readonly INSTANCE_NAME=aracne-instance

gcloud config set project $PROJECT_ID 
gcloud compute instances create $INSTANCE_NAME --zone $INSTANCE_ZONE
echo "instance $INSTANCE_NAME created at `date`"
#sleep 10 # if I start trying to copy files too soon, the connection will time out. But why? 

echo start copying files`date`
# copy program files and data files
gcloud compute copy-files aracne_1.1.jar coad_fix_first3genes.exp $INSTANCE_NAME:~/. --zone $INSTANCE_ZONE
#echo finished copying `date`

# run aracne
#gcloud compute ssh $INSTANCE_NAME --zone $INSTANCE_ZONE --command $ARACNE_SCRIPT

gcloud compute ssh $INSTANCE_NAME --zone $INSTANCE_ZONE --command "sudo apt-get update"
gcloud compute ssh $INSTANCE_NAME --zone $INSTANCE_ZONE --command "sudo apt-get install openjdk-7-jre"
gcloud compute ssh $INSTANCE_NAME --zone $INSTANCE_ZONE --command "java -version 2> java.version.txt"
gcloud compute ssh $INSTANCE_NAME --zone $INSTANCE_ZONE --command "java -jar aracne_1.1.jar -e coad_fix_first3genes.exp -o output -t tfs -p 0.05 -s 0 > result.txt"

# copy the result back
rm -r -f results
mkdir results
#gcloud compute copy-files $INSTANCE_NAME:~/output.* $INSTANCE_NAME:~/*.adj $INSTANCE_NAME:~/adjfiles $INSTANCE_NAME:~/logs ./results --zone $INSTANCE_ZONE
gcloud compute copy-files $INSTANCE_NAME:~/java.version.txt $INSTANCE_NAME:~/result.txt ./results --zone $INSTANCE_ZONE

# delete the VM instance
gcloud compute instances delete $INSTANCE_NAME --zone $INSTANCE_ZONE -q

# check the results
ls -lt results/

echo "double check nothing is left running"
gcloud compute instances list
gcloud compute disks list