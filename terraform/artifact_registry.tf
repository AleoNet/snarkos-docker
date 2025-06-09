resource "google_artifact_registry_repository" "snarkos" {
  repository_id = "snarkos-containers"
  location      = var.default_region
  format = "DOCKER"
  description   = "Docker Artifact Registry for snarkOS container builds"
  labels = {
    project     = var.project_name
  }
}
