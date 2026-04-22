module "iam" {
  source                          = "./modules/iam"
  project_id                      = var.project_id
  kafka_ingestion_service_account = var.kafka_ingestion_service_account
  dbt_service_account             = var.dbt_service_account
  workflow_service_account        = var.workflow_service_account
  admin_group_email               = var.admin_group_email
  pubsub_sub_service_account      = var.pubsub_sub_service_account
}

module "pubsub" {
  source      = "./modules/pubsub"
  project_id  = var.project_id
  topic_names = var.pubsub_topics
}

module "bigquery" {
  source           = "./modules/bigquery"
  project_id       = var.project_id
  region           = var.region
  datasets         = var.medallion_datasets
  gs_products_path = var.gs_products_path
  gs_stores_paths  = var.gs_stores_paths
}

module "artifact_registry" {
  source     = "./modules/artifact_registry"
  project_id = var.project_id
  region     = var.region
  repo_name  = var.artifact_repo_name
}

module "cloud_run" {
  source              = "./modules/cloud_run"
  project_id          = var.project_id
  region              = var.region
  service_account_run = module.iam.kafka_sa_email
  service_account_job = module.iam.dbt_sa_email
  depends_on          = [module.artifact_registry]
}

module "workflows" {
  source          = "./modules/workflows"
  project_id      = var.project_id
  region          = var.region
  service_account = module.iam.workflow_sa_email
  workflow_source = var.workflow_source_path
}

module "subscriptions" {
  source = "./modules/subscriptions"
  project_id = var.project_id
  us_topic_name = var.us_topic_name
  br_topic_name = var.br_topic_name
  us_dlt_name   = var.us_dlt_name
  br_dlt_name   = var.br_dlt_name
  bronze_dataset = var.bronze_dataset
  us_table_id    = var.us_table_id
  br_table_id    = var.br_table_id
  service_account_email = module.iam.pubsub_sub_sa_email
  depends_on = [
    module.pubsub,
    module.bigquery,
    module.iam
  ]
}
