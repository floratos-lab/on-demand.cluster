# this script starts the task from the client side, i.e. cygwin terminal
# this script automates the process of running an aracne job on the dynamically created standard instance of google cloud
# in the other words, no persistence disk is created or maintained for this task

gcloud config set project wise-mantra-567 # project name: geworkbench-Web
gcloud compute instances create zj-test-instance --zone us-central1-a
echo "created instance zj-test-instance ... `date`"
sleep 10 # if I start trying to copy files too soon, the connection will time out. But why? 

echo start copying `date`
# copy program files
gcloud compute copy-files ./aracne2 zj-test-instance:~/. --zone us-central1-a
gcloud compute copy-files ./usage.txt zj-test-instance:~/. --zone us-central1-a
gcloud compute copy-files ./run.aracne.sh zj-test-instance:~/. --zone us-central1-a

# copy data files
gcloud compute copy-files ./Bcell-100.exp zj-test-instance:~/. --zone us-central1-a
gcloud compute copy-files ./config_threshold.txt zj-test-instance:~/. --zone us-central1-a
gcloud compute copy-files ./hub.txt zj-test-instance:~/. --zone us-central1-a

echo done with copying `date`

# run aracne
gcloud compute ssh zj-test-instance --zone us-central1-a --command ./run.aracne.sh

# copy the result back
rm -r -f results
mkdir results
gcloud compute copy-files zj-test-instance:~/output.* ./results --zone us-central1-a
gcloud compute copy-files zj-test-instance:~/*.adj ./results --zone us-central1-a

# delete the VM instance
gcloud compute instances delete zj-test-instance --zone us-central1-a -q

# check the results
ls -lt results/
