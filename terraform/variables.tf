variable "project_id" {
  type        = string
  description = "The GCP Project ID where resources will be deployed."
}

variable "region" {
  type        = string
  description = "The default GCP region for resources."
}

variable "zone" {
  type        = string
  description = "The default GCP zone for resources."
}

variable "admin_group_email" {
  type        = string
  description = "The group email that is allowed to use/assign service accounts"
}

variable "kafka_ingestion_service_account" {
  type        = string
  description = "ID for the Kafka SA"
}

variable "dbt_service_account" {
  type        = string
  description = "ID for the dbt SA"
}

variable "workflow_service_account" {
  type        = string
  description = "ID for the workflow SA"
}


variable "medallion_datasets" {
  type        = list(string)
  description = "List of BigQuery datasets for the Medallion architecture."
}

variable "pubsub_topics" {
  type        = list(string)
  description = "List of PubSub topics and dead-letter topics to create."
}

variable "gs_products_path" {
  type        = string
  description = "GCS path for product CSV files."
}

variable "gs_stores_paths" {
  type        = list(string)
  description = "List of GCS paths for store JSON files."
}

variable "artifact_repo_name" {
  type        = string
  description = "The name of the Docker artifact repository."
}

variable "workflow_source_path" {
  type = string
}

variable "pubsub_sub_service_account" {
  type        = string
  description = "ID for the Pub/Sub Subscription SA"
}

variable "us_topic_name" {
  type        = string
  description = "The Pub/Sub topic for US sales"
}

variable "br_topic_name" {
  type        = string
  description = "The Pub/Sub topic for BR sales"
}

variable "us_dlt_name" {
  type        = string
  description = "The Dead Letter Topic for US sales"
}

variable "br_dlt_name" {
  type        = string
  description = "The Dead Letter Topic for BR sales"
}

variable "bronze_dataset" {
  type        = string
  description = "The Bronze BigQuery dataset name"
}

variable "us_table_id" {
  type        = string
  description = "The BigQuery table ID for US sales"
}

variable "br_table_id" {
  type        = string
  description = "The BigQuery table ID for BR sales"
}
