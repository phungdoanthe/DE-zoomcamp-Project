variable "credentials" {
  description = "path to gcloud credentials file"
  default     = "D:\\Study_DE\\project\\DE-zoomcamp-Project\\key\\de-zoomcamp-2026-485014-d31cf2df6ed3.json"
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

variable "start_year" {
  type = number
}

variable "end_year" {
  type = number
}