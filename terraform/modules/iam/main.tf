resource "google_service_account" "kafka_sa" {
  account_id   = var.kafka_ingestion_service_account
  project      = var.project_id
  display_name = "Kafka Ingestion Service Account"

  create_ignore_already_exists = true
}

resource "google_project_iam_member" "kafka_roles" {
  for_each = toset([
    "roles/pubsub.publisher",
    "roles/secretmanager.secretAccessor",
    "roles/artifactregistry.writer"
  ])

  project = var.project_id
  role    = each.key
  member  = "serviceAccount:${google_service_account.kafka_sa.email}"
}

resource "google_service_account" "dbt_sa" {
  account_id   = var.dbt_service_account
  project      = var.project_id
  display_name = "DBT Service Account"

  create_ignore_already_exists = true
}

resource "google_project_iam_member" "dbt_roles" {
  for_each = toset([
    "roles/analyticshub.admin",
    "roles/bigquery.admin",
    "roles/run.admin",
    "roles/dataplex.dataScanAdmin",
    "roles/monitoring.editor",
    "roles/storage.admin",
    "roles/workflows.admin",
    "roles/secretmanager.secretAccessor",
    "roles/artifactregistry.writer"
  ])

  project = var.project_id
  role    = each.key
  member  = "serviceAccount:${google_service_account.dbt_sa.email}"
}

resource "google_service_account" "workflow_sa" {
  account_id   = var.workflow_service_account
  project      = var.project_id
  display_name = "Workflow Service Account"

  create_ignore_already_exists = true
}

resource "google_project_iam_member" "workflow_roles" {
  for_each = toset([
    "roles/workflows.admin",
    "roles/artifactregistry.writer",
    "roles/run.invoker",
    "roles/run.admin"
  ])

  project = var.project_id
  role    = each.key
  member  = "serviceAccount:${google_service_account.workflow_sa.email}"
}


resource "google_service_account_iam_member" "kafka_sa_user" {
  service_account_id = google_service_account.kafka_sa.name
  role               = "roles/iam.serviceAccountUser"
  member             = "user:${var.admin_group_email}"
}

resource "google_service_account_iam_member" "dbt_sa_user" {
  service_account_id = google_service_account.dbt_sa.name
  role               = "roles/iam.serviceAccountUser"
  member             = "user:${var.admin_group_email}"
}

resource "google_service_account_iam_member" "workflow_sa_user" {
  service_account_id = google_service_account.workflow_sa.name
  role               = "roles/iam.serviceAccountUser"
  member             = "user:${var.admin_group_email}"
}

resource "google_service_account" "pubsub_sub_sa" {
  account_id   = var.pubsub_sub_service_account
  project      = var.project_id
  create_ignore_already_exists = true
}

resource "google_project_iam_member" "pubsub_sub_roles" {
  for_each = toset([
    "roles/bigquery.dataEditor",
    "roles/bigquery.metadataViewer",
    "roles/pubsub.publisher",
    "roles/pubsub.subscriber"
  ])

  project = var.project_id
  role    = each.key
  member  = "serviceAccount:${google_service_account.pubsub_sub_sa.email}"
}

resource "google_service_account_iam_member" "pubsub_sub_sa_user" {
  service_account_id = google_service_account.pubsub_sub_sa.name
  role               = "roles/iam.serviceAccountUser"
  member             = "user:${var.admin_group_email}"
}
