resource "google_bigquery_dataset" "medallion" {
  for_each   = toset(var.datasets)
  dataset_id = each.value
  location   = var.region
  project    = var.project_id
}

# External Tables (Products & Stores)
resource "google_bigquery_table" "products" {
  dataset_id = "mk_bronze"
  table_id   = "products"
  project    = var.project_id
  external_data_configuration {
    autodetect    = true
    source_format = "CSV"
    source_uris   = [var.gs_products_path]
  }
  depends_on = [google_bigquery_dataset.medallion]
}

resource "google_bigquery_table" "stores" {
  dataset_id = "mk_bronze"
  table_id   = "stores"
  project    = var.project_id
  external_data_configuration {
    autodetect    = true
    source_format = "NEWLINE_DELIMITED_JSON"
    source_uris   = var.gs_stores_paths
  }
  depends_on = [google_bigquery_dataset.medallion]
}

# Execute DDL for US and BR Sales
resource "google_bigquery_job" "create_us_sales" {
  job_id   = "create_us_sales_job"
  project  = var.project_id
  location = var.region
  query {
    query          = file("../bigquery/ddl/create_us_sales.sql")
    use_legacy_sql = false
  }
  depends_on = [google_bigquery_dataset.medallion]
}

resource "google_bigquery_job" "create_br_sales" {
  job_id   = "create_br_sales_job"
  project  = var.project_id
  location = var.region
  query {
    query          = file("../bigquery/ddl/create_br_sales.sql")
    use_legacy_sql = false
  }
  depends_on = [google_bigquery_dataset.medallion]
}
