#How to Run ARACNE and CINDY on Google Cloud Platform

*(draft under construction)*

Using Google Cloud Platform, you can run intensively computational task, e.g. ARACNE or CINDY, as long as you have internet connect, and pay for the resource that you actually use. You have the flexbility of choosing proper computing power (cores, memories) for each individual execuation.

You also have the option of using persistent disk so you don't have to transfer and/or preprocess the data every time, but it is left out of this tutorial assuming we would like to keep the cost to zero when we are not doing anything.

## How to get ready to use Google Cloud Platform

You need to have following items ready before you use Google Cloud Platform:

  1. You need a Google Account. You probably already have it if you use gmail or one of the many other services provided by Google.
  
  2. You need to set up a **billing account** so Google can charge you for the resource you use. See https://console.developers.google.com/billing
  
  3. Set up a project on Google Developer Console https://console.developers.google.com/project. You will need the project ID to do the actual computation. You also need to associate the billing account described in the previous step to this project.

  4. Download and install gcloud command line tool (Google Cloud SDK) from https://cloud.google.com/sdk/#Quick_Start.

  5. Authenticate gcloud and set up the key file.

  <a href="https://cloud.google.com/sdk/gcloud/reference/auth/login">gcloud auth login</a>

When you are asked to enter a passphrase for the key file, just enter nothing; otherwise, the process automated by the script will be interrupted many time asking for the passphrase. 

This step is a little annoying, but you only need to do it once.

## How to run ARACNE

  1. Download <a href="https://raw.githubusercontent.com/geworkbench-group/on-demand.cluster/master/aracne.java.sh">the script aracne.java.sh</a>, in which you need to change the variable PROJECT_ID to your own project ID, other scripts called from aracne.java.sh (cluster_properties.sh, cluster_setup.sh, install.sge.master.h, install.worker.sh), and Aracne.jar (that is to be provided seprately). (An earlier script called cloud.aracne.java.sh has everything hard-coded in. You may not want to use it to sbumit a new job, but it helps to undertand how various parts work together).

  2. Execute the script from a command prompt with your own project ID, the executable jar file, the exp file name, and other parameters, as in the following example:

    ./aracne.java.sh wise-mantra-567 Aracne.jar bcell-100.tab.txt GO_3700plus_TFs_HG-U95Av2.txt 0.00000001 "--seed 1"
 
  This script is developed and tested on cygwin on Windows, and it should work with most flavors of Linux/UNIX. Google Cloud unitily (gcloud command) also supports native Windows command line, cmd.exe, but the script has to be ported or re-written to Windows script.
  3. Check the result from the directory called *results*. If the job succeeds, you will see a file *results/result.txt*, which is the main output of the ARACNe java program.
  

## How to run CINDY

When CINDY is packaged as an executable jar file, it can be execuated using the same script as aracna.java.sh.

In case the script does not finish for any reason, you may want to run `./cluster_setup.sh down-full` to make sure no VM instance and/or disk left there that causes charge from Google.
