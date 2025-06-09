locals {
  reader_teams = [
    "anf@aleo.org",                        # Optional: real user
  ]

runners = [
    {
      name       = "github-runner-amd64"
      machine    = "e2-standard-2"
      arch_label = "x86_64-unknown-linux-gnu"
      image      = "ubuntu-os-cloud/ubuntu-2204-lts"
    }
  ]
}