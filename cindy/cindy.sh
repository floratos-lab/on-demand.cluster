#!/bin/bash
# this is modeld after aracne.java.sh

# instruction: this is how you run this script with some actual parameters
# $ ./cindy.sh wise-mantra-567 net_323.dat pc_10_tfs.txt pc_10_sigs.txt
# where $1 is the Google Cloud project ID; $2 is data matrix; $3 is TFS list; $4 is MOD list

if [ $# -ne 4 ]
    then
        echo "Usage: ./cindy.sh data_matrix tfs_list mod_list"
        exit
fi
START=`date +%s`
    
readonly PROJECT_ID=$1 # Google Cloud project ID

readonly EXECUTABLE_JAR=Cindy.jar
readonly MAX_ATTEMPTS=10
readonly OUTPUT_FOLDER="output"
readonly TFS_LIST=$3
readonly MOD_LIST=$4
readonly DATA_MATRIX=$2

gcloud config set project $PROJECT_ID 

source cluster_properties.sh > /dev/null
./cluster_setup.sh up-full
gcloud config set compute/zone $MASTER_NODE_ZONE

gcloud compute copy-files ./install.sge.master.sh ./cluster_properties.sh $MASTER_NODE_NAME_PATTERN:~/.
echo ">>> setting up SGE master ..."
gcloud compute ssh --ssh-flag="-o LogLevel=ERROR" $MASTER_NODE_NAME_PATTERN --command ./install.sge.master.sh &> /dev/null
rc=$?; if [[ $rc != 0 ]]; then ./cluster_setup.sh down-full; exit $rc; fi
echo ">>> done setting up the master: $MASTER_NODE_NAME_PATTERN"
readonly INSTANCE_NAME=$MASTER_NODE_NAME_PATTERN

gcloud compute copy-files $EXECUTABLE_JAR $TFS_LIST $MOD_LIST $DATA_MATRIX $INSTANCE_NAME:~/.

# worker node name formatter
function worker_node_name() {
    local instance_id="$1"
    printf $WORKER_NODE_NAME_PATTERN $instance_id
}
readonly -f worker_node_name

echo ">>> setting up SGE workers ..."
for ((i = 0; i < $WORKER_NODE_COUNT; i++)) do
    echo "Configuring worker node $(worker_node_name $i)"
    gcloud compute copy-files ./install.worker.sh $(worker_node_name $i):~/.
    gcloud compute ssh --ssh-flag="-o LogLevel=ERROR" $(worker_node_name $i) --command ./install.worker.sh &> /dev/null
    rc=$?; if [[ $rc != 0 ]]; then ./cluster_setup.sh down-full; exit $rc; fi

    gcloud compute copy-files "$EXECUTABLE_JAR" "$DATA_MATRIX" "$TFS_LIST" "$MOD_LIST" $(worker_node_name $i):~/.
done
echo ">>> done setting up $WORKER_NODE_COUNT workers"

rm -r -f $OUTPUT_FOLDER # clean-up output directory

# Stage 1 - threshold mode
echo ">>> starting Step 1 ..."
ATTEMPT=1
while [ ! -e $OUTPUT_FOLDER/tfs.txt ] || [ -s $OUTPUT_FOLDER/tfs.txt ]; do
    echo ">>> attempt $ATTEMPT"
    if (( ATTEMPT > MAX_ATTEMPTS )) ; then
	    echo "too many attempts, exiting"
		exit 1
    fi
	(( ATTEMPT++ ))
    echo ">>> running stage 1"
    STEP1_COMMAND="java -jar Cindy.jar -e $DATA_MATRIX -o $OUTPUT_FOLDER --tfs $TFS_LIST --mods $MOD_LIST -p 0.01 --seed 1 --thresholdmode"
    gcloud compute ssh --ssh-flag="-o LogLevel=ERROR" $INSTANCE_NAME --command "$STEP1_COMMAND"

    echo "$OUTPUT_FOLDER content:"
    gcloud compute ssh --ssh-flag="-o LogLevel=ERROR" $INSTANCE_NAME --command "ls -lt $OUTPUT_FOLDER"
    gcloud compute copy-files "$INSTANCE_NAME":~/"$OUTPUT_FOLDER" .
    
    # copy the preprocessed files to each node
    for ((i = 0; i < $WORKER_NODE_COUNT; i++)) do
        gcloud compute ssh --ssh-flag="-o LogLevel=ERROR" $(worker_node_name $i) --command "mkdir -p $OUTPUT_FOLDER"
        gcloud compute copy-files ./"$OUTPUT_FOLDER" $(worker_node_name $i):~/.
    done

    # Stage 2 - main computation
    # The file in the output directory "tfs.txt" has a list of all tfs for which stage two below needs to be run.
    # It can be empty, in which case the for loop below will not execute.
    ### Loop over the TFs
    START2=`date +%s`
    for tf in `cat $OUTPUT_FOLDER/tfs.txt`
    do
        echo ">>> running stage 2 for $tf"
        STEP2_COMMAND="java -jar Cindy.jar -e $DATA_MATRIX -o $OUTPUT_FOLDER --tfs $TFS_LIST --mods $MOD_LIST -p 0.01 --seed 1 -t ${tf} --threads 4"
        echo "#!/bin/bash
#$ -cwd -j y -o ./cindy.log
$STEP2_COMMAND" > qsub.job.sh
        gcloud compute copy-files qsub.job.sh $INSTANCE_NAME:~/.
        gcloud compute ssh --ssh-flag="-o LogLevel=ERROR" $INSTANCE_NAME --command "qsub ./qsub.job.sh"
    done #end for loop
    
    # check status
    QSTAT_COUNT=$(gcloud compute ssh --ssh-flag="-o LogLevel=ERROR" $INSTANCE_NAME --command "qstat|wc -l")
    while [ "$QSTAT_COUNT" -ne "0" ]
    do
        echo "$(( $QSTAT_COUNT - 2 )) jobs in queue..."
        sleep 60 # wait 60 seconds before checking the status again
        gcloud compute ssh --ssh-flag="-o LogLevel=ERROR" $INSTANCE_NAME --command "qstat"
        QSTAT_COUNT=$(gcloud compute ssh --ssh-flag="-o LogLevel=ERROR" $INSTANCE_NAME --command "qstat|wc -l")
    done
    END2=`date +%s`
    ELAPSED2=$(( ( $END2 - $START2 ) / 60 ))
    echo "step 2 time $ELAPSED2 minutes"

    # copy the files from each node
    for ((i = 0; i < $WORKER_NODE_COUNT; i++)) do
        gcloud compute copy-files $(worker_node_name $i):~/"$OUTPUT_FOLDER" .
    done
    gcloud compute copy-files ./"$OUTPUT_FOLDER" "$INSTANCE_NAME":~/.

done

# Stage 3 - consolidate
STEP3_COMMAND="java -jar Cindy.jar -e $DATA_MATRIX -o $OUTPUT_FOLDER --tfs $TFS_LIST --mods $MOD_LIST -p 0.01 --consolidate"
gcloud compute ssh --ssh-flag="-o LogLevel=ERROR" $INSTANCE_NAME --command "$STEP3_COMMAND"
gcloud compute copy-files "$INSTANCE_NAME":~/"$OUTPUT_FOLDER" .

# delete all the VM instances and disks
./cluster_setup.sh down-full &> /dev/null

# check the results
echo "What are in the $OUTPUT_FOLDER directory?"
ls -lt $OUTPUT_FOLDER

echo "please double check nothing is left running"
gcloud compute instances list
gcloud compute disks list

date
END=`date +%s`
ELAPSED=$(( ( $END - $START ) / 60 ))
echo "total time $ELAPSED minutes"
