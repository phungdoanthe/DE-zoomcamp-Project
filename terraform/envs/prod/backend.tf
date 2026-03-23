terraform {
  backend "gcs" {
    bucket  = "terraform-state-prod"
    prefix  = "infra"
  }
}