# ------------------------------------------------------------------------------
# PROVIDER CONFIGURATION
# ------------------------------------------------------------------------------
provider "google" {
  # Replace these with your actual project ID and desired region
  project = var.project
  region  = var.region
  credentials = file(var.credentials)
}

# ------------------------------------------------------------------------------
# GOOGLE CLOUD STORAGE BUCKET
# ------------------------------------------------------------------------------
resource "google_storage_bucket" "gcs_london_bicycle" {
  name          = var.bucket_name
  location      = var.region
  uniform_bucket_level_access = true
  force_destroy = true

  lifecycle_rule {
    action {
      type = "AbortIncompleteMultipartUpload"
    }
    condition {
      age = 1 // days
    }
  }
}

# ------------------------------------------------------------------------------
# GCS BUCKET FOLDERS
# ------------------------------------------------------------------------------
# Using a for_each loop to cleanly create the simulated folders
locals {
  years = range(var.start_year, var.end_year + 1)
}

resource "google_storage_bucket_object" "folders" {
  for_each = toset([for year in local.years: "raw/${year}/"])
  
  name    = each.value
  content = " " # Empty content simulates the folder
  bucket  = google_storage_bucket.gcs_london_bicycle.name
}

# ------------------------------------------------------------------------------
# BIGQUERY DATASET
# ------------------------------------------------------------------------------
resource "google_bigquery_dataset" "bq_london_bicycle" {
  dataset_id                  = var.bq_dataset_name
  friendly_name               = "Bicycle Dataset"
  description                 = "Dataset containing bicycle data"
  location                    = var.region

  # Optional: Default table expiration in milliseconds (e.g., 30 days)
  default_table_expiration_ms = 2592000000 
}

# ------------------------------------------------------------------------------
# DATAPROC CLUSTER
# ------------------------------------------------------------------------------
resource "google_dataproc_cluster" "dataproc_cluster" {
  name   = "london-bicycle-cluster"
  region = var.region

  cluster_config {
    master_config {
      num_instances = 1
      machine_type  = "n1-standard-4"
    }
    worker_config {
      num_instances = 2
      machine_type  = "n1-standard-4"
    }
    software_config {
      image_version = "2.0-debian10"
    }
  }
}