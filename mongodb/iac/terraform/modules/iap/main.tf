resource "google_service_account" "sa_iap" {
  account_id   = "iap-access"
  display_name = "IAP Access Service Account"
}

resource "google_project_iam_member" "roles_iap" {
  project = var.project_id
  role    = "roles/iap.tunnelResourceAccessor"
  member  = "serviceAccount:${google_service_account.sa_iap.email}"
}