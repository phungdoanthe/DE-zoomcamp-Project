#!/bin/bash

# Load environment variables from .env into shell
set -o allexport
source .env
set +o allexport

# copy code to GCS
gsutil cp -r repartition.py gs://$BUCKET_NAME/code

# Submit Dataproc job using those variables
gcloud dataproc jobs submit pyspark gs://$BUCKET_NAME/code/repartition.py \
  --cluster=$CLUSTER_NAME \
  --region=$REGION \
  --properties="spark.executorEnv.BUCKET_NAME=$BUCKET_NAME, spark.executorEnv.START_YEAR=$START_YEAR, spark.executorEnv.END_YEAR=$END_YEAR"

echo "Job submitted successfully!"