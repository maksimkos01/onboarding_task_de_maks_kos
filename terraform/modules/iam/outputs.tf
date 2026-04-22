output "kafka_sa_email" {
  value       = google_service_account.kafka_sa.email
  description = "The email of the Kafka service account"
}

output "dbt_sa_email" {
  value = google_service_account.dbt_sa.email
}

output "workflow_sa_email" {
  value = google_service_account.workflow_sa.email
}

output "pubsub_sub_sa_email" {
  value       = google_service_account.pubsub_sub_sa.email
  description = "The email of the Pub/Sub Subscription service account"
}
