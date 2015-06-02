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

## How to run ARACNE

  1. Download the script and jar file.

  2. Execute the script.

## How to run CINDY

*TO DO*
