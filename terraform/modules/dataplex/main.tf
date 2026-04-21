resource "google_dataplex_datascan" "scans" {
  for_each = toset(var.auto_dq_tables)

  location     = var.region
  project      = var.project_id
  data_scan_id = "mk-${replace(each.key, "_", "-")}-dqc-scan"

  data {
    resource = "//bigquery.googleapis.com/projects/${var.project_id}/datasets/mk_gold/tables/${each.value}"
  }
  execution_spec {
    trigger {
      on_demand {}
    }
  }
  data_quality_spec {
    sampling_percent = 100
  }
}
