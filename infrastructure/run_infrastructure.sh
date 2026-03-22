#!/bin/bash
set -e

# Load environment variables safely
set -o allexport
source .env
set +o allexport

# Pass variables to Terraform
export TF_VAR_start_year="$START_YEAR"
export TF_VAR_end_year="$END_YEAR"

# Run Terraform
terraform init
terraform apply -auto-approve

echo "Applying infrastructure for years $START_YEAR to $END_YEAR"