resource "google_service_account" "team_accounts" {
  account_id   = "anf-builder"
  display_name = "Anf Team Artifact Builder"
}

resource "google_service_account" "reader_teams" {
  for_each     = toset(local.reader_teams)
  account_id   = "${each.key}-reader"
  display_name = "${each.key} Artifact Registry Reader"
  project      = var.project_name
}
