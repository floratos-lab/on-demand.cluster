# this is based on cloud.aracne.java.sh but allows the actual jar file, data file, and parameters

# instruction: this is how you run this script with some actual parameters
# $ ./aracne.java.sh wise-mantra-567 aracne_1.1.jar coad_fix_first3genes.exp "coad_fix_first3genes.exp -o output -t tfs -p 0.05 -s 0"
# where $1 is the Google Cloud project ID; $2 is the complete java command with all the parameters and the options, quoted.

if [ $# -ne 4 ]
    then
        echo "Usage: ./aracne.java.sh project_id executable_jar exp_file \"other parameters ...\""
        exit
fi
    
readonly PROJECT_ID=$1 # Google Cloud project ID
readonly EXECUTABLE_JAR=$2
readonly EXP_FILE=$3
readonly OTHER_PARAMETERS=$4

readonly INSTANCE_ZONE=us-central1-a
readonly INSTANCE_NAME=aracne-instance

gcloud config set project $PROJECT_ID 
gcloud compute instances create $INSTANCE_NAME --zone $INSTANCE_ZONE
echo "instance $INSTANCE_NAME created at `date`"

echo start copying files `date`
# copy program files and data files
gcloud compute copy-files $EXECUTABLE_JAR $EXP_FILE $INSTANCE_NAME:~/. --zone $INSTANCE_ZONE
#echo finished copying `date`

# install Java
gcloud compute ssh $INSTANCE_NAME --zone $INSTANCE_ZONE --command "sudo apt-get update"
gcloud compute ssh $INSTANCE_NAME --zone $INSTANCE_ZONE --command "sudo apt-get -y install openjdk-7-jre"
gcloud compute ssh $INSTANCE_NAME --zone $INSTANCE_ZONE --command "java -version 2> java.version.txt"

# run aracne
FULL_COMMAND="java -jar $EXECUTABLE_JAR -e $EXP_FILE $OTHER_PARAMETERS > result.txt"
echo "The command to be execuated: $FULL_COMMAND"
gcloud compute ssh $INSTANCE_NAME --zone $INSTANCE_ZONE --command "$FULL_COMMAND"

# copy the result back
rm -r -f results
mkdir results
gcloud compute copy-files $INSTANCE_NAME:~/java.version.txt $INSTANCE_NAME:~/result.txt ./results --zone $INSTANCE_ZONE

# delete the VM instance
gcloud compute instances delete $INSTANCE_NAME --zone $INSTANCE_ZONE -q

# check the results
ls -lt results/

echo "please double check nothing is left running"
gcloud compute instances list
gcloud compute disks list
