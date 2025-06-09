resource "google_artifact_registry_repository" "snarkos" {
  repository_id = "${var.environment}-snarkos-containers"
  location      = var.default_region
  format        = "DOCKER"
  description   = "Docker Artifact Registry for snarkOS container builds"
  labels = {
    environment = var.environment
    project     = var.project_name
  }
}

# Look up the numeric project number for IAM bindings
data "google_project" "current" {
  project_id = var.project_name
}

# Optional service account for future CI/CD use (not Cloud Build)
resource "google_service_account" "artifact_builder" {
  account_id   = "artifact-builder"
  display_name = "Artifact Builder Service Account"
}

# IAM: Allow the artifact_builder SA to write to the repo
resource "google_artifact_registry_repository_iam_member" "builder_writer" {
  location   = google_artifact_registry_repository.snarkos.location
  repository = google_artifact_registry_repository.snarkos.repository_id
  role       = "roles/artifactregistry.writer"
  member     = "serviceAccount:${google_service_account.artifact_builder.email}"
}

# IAM: Allow Cloud Build's default SA to push images
resource "google_artifact_registry_repository_iam_member" "cloudbuild_writer" {
  location   = google_artifact_registry_repository.snarkos.location
  repository = google_artifact_registry_repository.snarkos.repository_id
  role       = "roles/artifactregistry.writer"
  member     = "serviceAccount:${data.google_project.current.number}@cloudbuild.gserviceaccount.com"
}

# Optional: Public read-only access for docker pull
# resource "google_artifact_registry_repository_iam_member" "public_reader" {
#   location   = google_artifact_registry_repository.snarkos.location
#   repository = google_artifact_registry_repository.snarkos.repository_id
#   role       = "roles/artifactregistry.reader"
#   member     = "allUsers"
# }
