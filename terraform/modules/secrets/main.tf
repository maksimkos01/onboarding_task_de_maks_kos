resource "google_secret_manager_secret" "user_secret" {
  secret_id = var.user_secret
  project   = var.project_id
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret" "user_password" {
  secret_id = var.user_password
  project   = var.project_id
  replication {
    auto {}
  }
}
