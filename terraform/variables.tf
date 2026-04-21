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

variable "auto_dq_tables" {
  type        = list(string)
  description = "List of gold tables for data quality checks"
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

variable "user_secret" {
  type = string
}

variable "user_password" {
  type = string
}
