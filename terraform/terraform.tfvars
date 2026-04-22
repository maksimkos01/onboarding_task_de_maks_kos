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

pubsub_sub_service_account = "mk-pubsub-sub-sa"

us_topic_name = "mk-us-sales-topic"
br_topic_name = "mk-br-sales-topic"
us_dlt_name   = "mk-us-sales-dlt"
br_dlt_name   = "mk-br-sales-dlt"
bronze_dataset = "mk_bronze"
us_table_id    = "us_sales"
br_table_id    = "br_sales"
