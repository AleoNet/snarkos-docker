terraform {
  source = "../../terraform"
}

locals {
  project_name           = "docker-registry-anf"
  location               = "us-east1"
  prefix                 = "terraform/state"
  environment            = "canary"
  default_region         = "us-east1"
  default_region_zones   = ["us-east1-b", "us-east1-c", "us-east1-d"]
}


remote_state {
  backend = "gcs"
  config = {
    bucket   = "${local.project_name}-tfstate"
    prefix   = local.prefix
    project  = local.project_name
    location = local.location
  }
}

inputs = {
  project_name         = local.project_name
  environment          = local.environment
  default_region       = local.default_region
  default_region_zones = local.default_region_zones
}
