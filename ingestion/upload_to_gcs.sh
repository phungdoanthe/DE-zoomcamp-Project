#!/bin/bash
set -e

# Verify credentials file exists
if [ ! -f "$GOOGLE_APPLICATION_CREDENTIALS" ]; then
  echo "Error: credentials file not found at $GOOGLE_APPLICATION_CREDENTIALS"
  exit 1
fi

# Explicitly authenticate gcloud with the service account
gcloud auth activate-service-account --key-file="$GOOGLE_APPLICATION_CREDENTIALS"
gcloud config set project "$PROJECT_ID"

echo "Uploading data to gs://$GCS_BUCKET_NAME/raw/..."
gsutil -m cp -n -r data/ gs://$GCS_BUCKET_NAME/raw/
echo "Upload complete."