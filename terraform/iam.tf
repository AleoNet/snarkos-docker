# Lookup project number for IAM
data "google_project" "current" {
  project_id = var.project_name
}

# IAM for artifact builder
resource "google_artifact_registry_repository_iam_member" "builds_writer" {
  location   = google_artifact_registry_repository.snarkos.location
  repository = google_artifact_registry_repository.snarkos.repository_id
  role       = "roles/artifactregistry.writer"
  member     = "serviceAccount:${google_service_account.team_accounts.email}"
}

# IAM for readers
resource "google_artifact_registry_repository_iam_member" "team_readers" {
  for_each   = toset(local.reader_teams)
  location   = google_artifact_registry_repository.snarkos.location
  repository = google_artifact_registry_repository.snarkos.repository_id
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:${google_service_account.reader_teams[each.key].email}"
}

