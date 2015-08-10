# a collection of command commands
# this file is NOT meant to run as it is

# see this
# https://cloud.google.com/compute/docs/quickstart

#https://cloud.google.com/sdk/gcloud/reference/auth/login
# command to login before you can do anything else
gcloud auth login

# create an instance with all default parameters
gcloud compute instances create my-instance --zone us-central1-a
# the default machine image does not have g++ or java or javac, but does have perl and python
# the default image I got is debian ( 3.2.0-4-amd64 #1 SMP Debian 3.2.65-1+deb7u1 x86_64 GNU/Linux )

# log into the instance
gcloud compute ssh instance-name --zone us-central1-a

# list the instances
gcloud compute instances list

# delete an instance
gcloud compute instances delete instance-name --zone us-central1-a

# delete all the instances and disks set up for the cluster experiment
/cluster_setup.sh down-full

# working example of copying the entire directory tree
gcloud compute copy-files contrib gwb-grid-mm:~ --zone us-central1-a

# working example of copying one file
gcloud compute copy-files getconsensusnet.pl gwb-grid-mm:~ --zone us-central1-a
