#!/bin/bash
set -e

set -o allexport
source .env
set +o allexport

export DEST_DIR=$CONNECTOR_DIR

URL="https://repo1.maven.org/maven2/com/google/cloud/bigdataoss/gcs-connector/hadoop3-2.2.5/gcs-connector-hadoop3-2.2.5.jar"
DEST_DIR=".cloud/dataproc/connectors"

mkdir -p "$DEST_DIR"
curl -fL "$URL" -o "$DEST_DIR/gcs-connector-hadoop3-2.2.5.jar"

echo "Download complete."