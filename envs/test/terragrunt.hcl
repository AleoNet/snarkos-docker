terraform {
  source = "../../terraform"
}

locals {
  project_name           = "aleo-provable-migration-test"
  location               = "us-east1"
  prefix                 = "terraform/state"
  environment            = "canary"
  default_region         = "us-east1"
  default_region_zones   = ["us-east1-b", "us-east1-c", "us-east1-d"]
  vpc_network            = "${local.project_name}-vpc"
  vpc_subnetwork         = "${local.project_name}-subnet"
  vpc_ip_cidr_range      = "10.10.0.0/16"

  external_validator_ips = [ "99.48.167.170", "210.96.5.120", "34.91.51.58", "99.48.167.131", "51.195.106.72", "135.181.228.130", "15.235.53.78", "3.111.151.121", "176.34.245.165", "63.33.135.11", "34.255.57.112", "52.49.211.12", "52.53.191.13", "34.138.133.193", "18.176.255.58", "146.59.69.111", "195.181.160.187", "192.69.194.82", "185.19.218.65", "213.136.69.252", "52.78.199.191", "141.94.3.35", "156.67.63.37", "149.28.81.150", "34.16.71.106", "72.251.4.130", "52.10.113.87", "15.204.29.32", "35.217.14.199"]
  # external_validator_ips   = ["0.0.0.0/0"]
  external_validator_peers = ["0.0.0.0/0"]

  validator_machine_type = "c3d-highcpu-60"    # (60 vCPUs, 120 GB Memory)
  client_machine_type    = "e2-highcpu-32"     # (32 vCPUs, 32 GB Memory)
  boot_machine_type      = "e2-highcpu-32"     # (32 vCPUs, 32 GB Memory)
  snapshot_machine_type  = "e2-highcpu-32"     # (32 vCPUs, 32 GB Memory)
  ssh_keys               = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPtwChogeZB6S56lmKWHT6FSUStMZ8iHKM4cEikgTnH/ sergii@aleo.org",
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICpwFqsHvtBRQkUswNOPfvWBcKesZaJNjZBT1+S2kz6m jeff@aleo.org",
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDI21qxPVOxxBoQHldl4nL5sjaq+PL3UQ29WJWhuZAR/ john@aleo.org"
  ]
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
  vpc_network          = local.vpc_network
  vpc_subnetwork       = local.vpc_subnetwork
  vpc_ip_cidr_range    = local.vpc_ip_cidr_range
  external_validator_ips   = local.external_validator_ips
  external_validator_peers = local.external_validator_peers

  vm_config = {
    # validator = {
    #   count        = 1
    #   disk_size    = 1200
    #   network      = local.vpc_network
    #   subnetwork   = local.vpc_subnetwork
    #   ssh_keys     = local.ssh_keys
    #   machine_type = local.validator_machine_type 
    # }
    # client = {
    #   count        = 4
    #   disk_size    = 600
    #   network      = local.vpc_network
    #   subnetwork   = local.vpc_subnetwork
    #   ssh_keys     = local.ssh_keys      
    #   machine_type = local.client_machine_type    
    # }
    # boot = {
    #   count        = 4
    #   disk_size    = 600
    #   network      = local.vpc_network
    #   subnetwork   = local.vpc_subnetwork
    #   ssh_keys     = local.ssh_keys
    #   machine_type = local.boot_machine_type      
    # }
    # snapshot = {
    #   count        = 1
    #   disk_size    = 1200
    #   network      = local.vpc_network
    #   subnetwork   = local.vpc_subnetwork
    #   ssh_keys     = local.ssh_keys
    #   machine_type = local.snapshot_machine_type
    # }
  }

  boot_image = "projects/ubuntu-os-cloud/global/images/ubuntu-minimal-2204-jammy-v20240318"
}