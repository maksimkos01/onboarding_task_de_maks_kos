resource "google_workflows_workflow" "medallion_pipeline" {
  name            = "mk-medallion-pipeline"
  region          = var.region
  project         = var.project_id
  service_account = var.service_account
  source_contents = file(var.workflow_source)
}

resource "google_cloud_scheduler_job" "workflow_scheduler" {
  name     = "mk-daily-medallion-sync"
  schedule = "0 5 * * *"
  region   = var.region
  project  = var.project_id

  http_target {
    http_method = "POST"
    uri         = "https://workflowexecutions.googleapis.com/v1/${google_workflows_workflow.medallion_pipeline.id}/executions"
    body        = base64encode("{}")

    oauth_token {
      service_account_email = var.service_account
    }
  }
}
