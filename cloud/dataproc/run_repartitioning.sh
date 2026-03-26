#!/bin/bash
set -e

# copy code to GCS
gsutil cp -r ./cloud/dataproc/repartition.py gs://$GCS_BUCKET_NAME/code/

# Submit Dataproc job using those variables
gcloud dataproc jobs submit pyspark gs://$GCS_BUCKET_NAME/code/repartition.py \
  --cluster=$CLUSTER_NAME \
  --region=$REGION \
  -- $GCS_BUCKET_NAME $START_YEAR $END_YEAR

echo "Job submitted successfully!"