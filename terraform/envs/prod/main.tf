module "gcs" {
  source      = "../../modules/gcs"
  bucket_name = var.bucket_name
  region      = var.region
}

module "bigquery" {
  source     = "../../modules/bigquery"
  dataset_id = var.bq_dataset_name
  region     = var.region
}

module "dataproc" {
  source                 = "../../modules/dataproc"
  cluster_name           = "dataproc-cluster"
  region                 = var.region
  zone                   = var.zone
  service_account_email  = google_service_account.default.email
}