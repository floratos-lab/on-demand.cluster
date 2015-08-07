Introduction
=================

This is an experimental project of dynamically creating SGE cluster on the platform of Google Cloud Compute Engine, and submitting jobs to it. One of the first goals is to start the process with a script that does not need manual interaction of the user.

See https://cloud.google.com/compute/

Because Google Cloud is under active development, it is a good idea to run `gcloud components update` once in a while.

###Environment
The scripts are tested using cygwin on Windows (GNU bash, version 4.1.17). I assume that they work the same way on any normal Linux/UNIX systems. You also must have Google Cloud SDK installed before being able to run the scripts.

####References
* [qsun man page](http://gridscheduler.sourceforge.net/htmlman/htmlman1/qsub.html)
* [Sun Grid Engine queue configuration file format](http://gridscheduler.sourceforge.net/htmlman/htmlman5/queue_conf.html)
