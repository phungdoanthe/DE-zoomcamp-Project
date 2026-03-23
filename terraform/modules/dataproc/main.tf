resource "google_dataproc_cluster" "this" {
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