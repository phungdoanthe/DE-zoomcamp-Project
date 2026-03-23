resource "google_bigquery_dataset" "bq_london_bicycle" {
  dataset_id                  = var.bq_dataset_name
  friendly_name               = "Bicycle Dataset"
  description                 = "Dataset containing bicycle data"
  location                    = var.region

  # Optional: Default table expiration in milliseconds (e.g., 30 days)
  default_table_expiration_ms = 2592000000 
}