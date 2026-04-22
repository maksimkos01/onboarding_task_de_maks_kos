resource "google_pubsub_subscription" "us_sales_bq_sub" {
  name    = "mk-us-sales-bq-sub"
  project = var.project_id
  
  topic   = "projects/${var.project_id}/topics/${var.us_topic_name}"

  bigquery_config {
    table                 = "${var.project_id}:${var.bronze_dataset}.${var.us_table_id}"
    use_table_schema      = true
    service_account_email = var.service_account_email
  }

  dead_letter_policy {
    dead_letter_topic     = "projects/${var.project_id}/topics/${var.us_dlt_name}"
    max_delivery_attempts = 5
  }
}

resource "google_pubsub_subscription" "br_sales_bq_sub" {
  name    = "mk-br-sales-bq-sub"
  project = var.project_id
  
  topic   = "projects/${var.project_id}/topics/${var.br_topic_name}"

  bigquery_config {
    table                 = "${var.project_id}:${var.bronze_dataset}.${var.br_table_id}"
    use_table_schema      = true
    service_account_email = var.service_account_email
  }

  dead_letter_policy {
    dead_letter_topic     = "projects/${var.project_id}/topics/${var.br_dlt_name}"
    max_delivery_attempts = 5
  }
}

# Subscription to catch and hold messages sent to the US Dead Letter Topic
resource "google_pubsub_subscription" "us_dlt_sub" {
  name    = "mk-us-sales-dlt-sub"
  project = var.project_id
  topic   = "projects/${var.project_id}/topics/${var.us_dlt_name}"
  message_retention_duration = "604800s" 
}

# Subscription to catch and hold messages sent to the BR Dead Letter Topic
resource "google_pubsub_subscription" "br_dlt_sub" {
  name    = "mk-br-sales-dlt-sub"
  project = var.project_id
  topic   = "projects/${var.project_id}/topics/${var.br_dlt_name}"
  message_retention_duration = "604800s" 
}
