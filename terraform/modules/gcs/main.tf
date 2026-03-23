resource "google_storage_bucket" "gcs_london_bicycle" {
  name          = var.bucket_name
  location      = var.region
  uniform_bucket_level_access = true

  lifecycle_rule {
    action {
      type = "AbortIncompleteMultipartUpload"
    }
    condition {
      age = 1 // days
    }
  }
}
