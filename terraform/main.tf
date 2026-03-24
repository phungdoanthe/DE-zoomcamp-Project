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
# ----------------------------------------  --------------------------------------
resource "google_service_account" "default" {
  account_id   = var.service_account
  display_name = "Service Account"
}

resource "google_dataproc_cluster" "dataproc" {
  name   = "dataproc-cluster"
  region = var.region

  cluster_config {
    # Compute Engine config
    gce_cluster_config {
      zone        = var.zone
      network     = "default"
      internal_ip_only = true
      metadata = {
        "disable-legacy-endpoints" = "true"
      }

      service_account = google_service_account.default.email
      service_account_scopes = [
        "cloud-platform"
      ]
    }

    master_config {
      num_instances = 1
      machine_type  = "n4-standard-2"

      disk_config {
        boot_disk_type    = "pd-balanced"   # closest Terraform-supported type
        boot_disk_size_gb = 100
      }
    }

    software_config {
      # Dataproc image version
      image_version = var.dataproc_image_version

      # Spark and other cluster properties
      override_properties = {
        "dataproc:dataproc.allow.zero.workers" = "true"
        "spark:spark.driver.memory"            = "4g"
      }
    }

    endpoint_config {
      enable_http_port_access = true
    }
  }
}