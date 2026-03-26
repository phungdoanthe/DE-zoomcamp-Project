variable "credentials" {
  description = "path to gcloud credentials file"
  default     = "../key/de-zoomcamp-2026-485014.json"
}
variable "project" {
  description = "project"
  default     = "de-zoomcamp-2026-485014"
}

variable "region" {
  description = "project location"
  default     = "asia-southeast1"
}

variable "bq_dataset_name" {
  description = "bigquery dataset name"
  default     = "london_bicycle"
}


variable "bucket_name" {
  description = "gcloud storage bucket name"
  default     = "london_bicycle_485014" # Must be globally unique across all GCS buckets
}

variable "zone" {
  description = "GCP zone for Dataproc cluster"
  default     = "asia-southeast1-c"
}

variable "cluster_name" {
  description = "GCP network for Dataproc cluster"
  default     = "de-zoomcamp-cluster"
}

variable "master_machine_type" {
  description = "Machine type for the master node"
  default     = "n1-standard-4"
}

variable "dataproc_image_version" {
  description = "Dataproc image version"
  default     = "2.2.76-debian12"
}

variable "service_account" {
  description = "Service account id"
  default = "475663472492-compute@developer.gserviceaccount.com"
}