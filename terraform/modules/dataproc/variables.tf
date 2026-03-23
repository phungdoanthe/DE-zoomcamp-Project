variable "zone" {
  description = "GCP zone for Dataproc cluster"
  default     = "asia-southeast1-c"
}

variable "region" {
  description = "project location"
  default     = "asia-southeast1"
}

variable "dataproc_image_version" {
  description = "Dataproc image version"
  default     = "2.2.76-debian12"
}