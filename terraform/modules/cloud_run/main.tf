resource "google_cloud_run_v2_service" "kafka_consumer" {
  name     = "mk-consumer-service"
  location = var.region
  project  = var.project_id

  template {
    service_account = var.service_account_run
    containers {
      image = "us-docker.pkg.dev/cloudrun/container/hello"
    }
  }

  lifecycle {
    ignore_changes = [
      template[0].containers[0].image,
    ]
  }
}

resource "google_cloud_run_v2_job" "dbt_job" {
  name     = "mk-dbt-medallion-job"
  location = var.region
  project  = var.project_id

  template {
    template {
      service_account = var.service_account_job
      containers {
        image = "us-docker.pkg.dev/cloudrun/container/hello"
      }
    }
  }

  lifecycle {
    ignore_changes = [
      template[0].template[0].containers[0].image,
    ]
  }
}
