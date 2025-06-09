resource "google_service_account" "team_accounts" {
  account_id   = "anf-builder"
  display_name = "Anf Team Artifact Builder"
}