# the main script having all the steps of experiment together

./cluster_setup.sh up-full
gcloud compute copy-files ./install.sge.master.sh gwb-grid-mm:~/. --zone us-central1-a
gcloud compute copy-files ./test.sh gwb-grid-mm:~/. --zone us-central1-a
#echo 'done with copying for the master'
gcloud compute ssh gwb-grid-mm --zone us-central1-a --command ./install.sge.master.sh

gcloud compute copy-files ./install.worker.sh gwb-grid-ww-0:~/. --zone us-central1-a
gcloud compute copy-files ./install.worker.sh gwb-grid-ww-1:~/. --zone us-central1-a
#echo 'finished copying for the workers ....'
gcloud compute ssh gwb-grid-ww-0 --zone us-central1-a --command ./install.worker.sh
gcloud compute ssh gwb-grid-ww-1 --zone us-central1-a --command ./install.worker.sh

# log in to the master to do the test
gcloud compute ssh gwb-grid-mm --zone us-central1-a
# log in to the workers to check the result
gcloud compute ssh gwb-grid-ww-0 --zone us-central1-a
gcloud compute ssh gwb-grid-ww-1 --zone us-central1-a

# for testing purpose, the clusters are destroyed right afterwards
#./cluster_setup.sh down-full
