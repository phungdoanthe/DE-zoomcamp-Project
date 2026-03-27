#!/bin/bash
set -e

# Fix Windows line endings in all scripts
find . -type f -name "*.sh" -exec sed -i 's/\r$//' {} +
sed -i 's/\r//' .env

# Load environment variables
if [ -f .env ]; then
  set -o allexport
  source .env
  set +o allexport
fi
echo "Environment variables loaded successfully."

# Ensure uv exists
if ! command -v uv &> /dev/null; then
  echo "Installing uv..."
  curl -LsSf https://astral.sh/uv/install.sh | sh || \
    pip install uv --break-system-packages
  source $HOME/.local/bin/env
fi

# Sync dependencies and run
uv sync
echo "Dependencies installed."

uv run python ingestion/download.py --years 2019-2022
echo "Data download completed successfully."

# Ensure Terraform exists
if ! command -v terraform &> /dev/null; then
  echo "Installing Terraform..."

  # Ensure unzip exists
  if ! command -v unzip &> /dev/null; then
    echo "Installing unzip..."
    sudo apt update && sudo apt install unzip -y
  fi

  wget -O /tmp/terraform.zip https://releases.hashicorp.com/terraform/1.7.5/terraform_1.7.5_linux_amd64.zip
  unzip -o /tmp/terraform.zip -d /usr/local/bin/
  sudo mv /tmp/terraform /usr/local/bin/
fi

bash terraform/run_infrastructure.sh
echo "Infrastructure setup completed successfully."

bash ingestion/upload_to_gcs.sh
echo "Data upload to GCS completed successfully."

bash cloud/dataproc/run_repartitioning.sh
echo "Data repartitioning completed successfully."