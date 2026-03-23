variable "bucket_name" {
  description = "gcloud storage bucket name"
  default     = "london_bicycle_485014" # Must be globally unique across all GCS buckets
}

variable "region" {
  description = "project location"
  default     = "asia-southeast1"
}