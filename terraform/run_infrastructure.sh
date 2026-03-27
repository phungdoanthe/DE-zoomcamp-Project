#!/bin/bash
set -e

# Pass variables to Terraform
export TF_VAR_start_year="$START_YEAR"
export TF_VAR_end_year="$END_YEAR"

# Run Terraform
terraform -chdir=terraform init
terraform -chdir=terraform apply -auto-approve

echo "Applying infrastructure for years $START_YEAR to $END_YEAR"