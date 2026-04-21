project_id         = "syntio-onboarding-prod"
region             = "europe-west1"
zone               = "europe-west1-b"
artifact_repo_name = "mk-docker-repo"

admin_group_email = "maksim.kos@legacy.syntio.net"

kafka_ingestion_service_account = "mk-kafka-sa"
dbt_service_account             = "mk-dbt-sa"
workflow_service_account        = "mk-workflow-sa"


medallion_datasets = [
  "mk_bronze",
  "mk_silver",
  "mk_gold"
]

pubsub_topics = [
  "mk-us-sales-topic",
  "mk-br-sales-topic",
  "mk-us-sales-dlt",
  "mk-br-sales-dlt"
]

gs_products_path = "gs://syn-onboard-product-prod/*.csv"

gs_stores_paths = [
  "gs://syn-onboard-stores-prod/2025-04-15/*",
  "gs://syn-onboard-stores-prod/2025-07-01/*"
]

workflow_source_path = "../workflow/pipeline-workflow.yaml"
