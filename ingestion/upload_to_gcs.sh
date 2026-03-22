#!/bin/bash

# Load .env file
set -o allexport
source .env
set +o allexport


export GOOGLE_APPLICATION_CREDENTIALS=$GOOGLE_APPLICATION_CREDENTIALS

gsutil -m cp -r data/ gs://$GCS_BUCKET_NAME/raw/

