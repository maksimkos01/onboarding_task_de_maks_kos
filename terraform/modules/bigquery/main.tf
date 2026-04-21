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
resource "google_bigquery_table" "us_sales" {
  dataset_id = "mk_bronze"
  table_id   = "us_sales"
  project    = var.project_id
  schema = file("../bigquery/ddl/us_sales_schema.json")
  depends_on = [google_bigquery_dataset.medallion]

}

resource "google_bigquery_table" "br_sales" {
  dataset_id = "mk_bronze"
  table_id   = "br_sales"
  project    = var.project_id
  schema = file("../bigquery/ddl/br_sales_schema.json")
  depends_on = [google_bigquery_dataset.medallion]
}
