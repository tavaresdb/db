# Definição do provider
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
  }
  required_version = ">= 1.3"
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# Módulo de rede
module "network" {
  source     = "./modules/network"
  project_id = var.project_id
  region     = var.region
}

# Módulo de NAT
module "nat" {
  source     = "./modules/nat"
  project_id = var.project_id
  region     = var.region
  network    = module.network.network_name
}

# Módulo de IAP
module "iap" {
  source     = "./modules/iap"
  project_id = var.project_id
}

# Módulo de Compute Engine (Instâncias dedicadas ao MongoDB com replicaSet)
module "replicaSet_mongodb" {
  source               = "./modules/instances"
  counter              = 3
  instance_name_prefix = "mongo"
  project_id           = var.project_id
  zones                = var.zones
  machine_type         = var.machine_type
  tags                 = ["mongodb", "personal-project"]
  network              = module.network.network_name
  subnetwork           = module.network.subnetwork_name
  additional_disk      = true
  additional_disk_size = var.additional_disk_size
  startup_script       = ""
  ssh_keys             = var.ssh_keys
}

# Módulo de Compute Engine (Instância dedicada ao Ansible, de modo que o Control Node configure as máquinas do inventário)
module "controlNode_ansible" {
  source               = "./modules/instances"
  counter              = 1
  instance_name_prefix = "ansible"
  project_id           = var.project_id
  zones                = [var.zones[0]]
  machine_type         = var.machine_type
  tags                 = ["personal-project"]
  network              = module.network.network_name
  subnetwork           = module.network.subnetwork_name
  additional_disk      = false
  additional_disk_size = 0
  startup_script       = var.ansible_startup_script
  ssh_keys             = var.ssh_keys
}