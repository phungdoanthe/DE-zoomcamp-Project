#!/bin/bash

# Load .env file
set -o allexport
source .env
set +o allexport


export GOOGLE_APPLICATION_CREDENTIALS=$GOOGLE_APPLICATION_CREDENTIALS

# Upload folders to Google Cloud Storage (GCS)
for YEAR in 2019 2020 2021; do
    gsutil -m cp -r data/$YEAR gs://$GCS_BUCKET_NAME/raw/$YEAR
done

