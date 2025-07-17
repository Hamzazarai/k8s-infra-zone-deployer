locals {
  providers = {
    proxmox    = "./modules/proxmox_cluster"
    aws        = "./modules/aws_cluster"
    cloudstack = "./modules/cloudstack_cluster"
  }
}

module "selected_cluster" {
  source = local.providers[var.provider_type]

  zone_name          = var.zone_name
  master_count       = var.master_count
  worker_count       = var.worker_count
  master_cpu         = var.master_cpu
  master_ram         = var.master_ram
  master_disk        = var.master_disk
  worker_cpu         = var.worker_cpu
  worker_ram         = var.worker_ram
  worker_disk        = var.worker_disk
  nat_network_cidr   = var.nat_network_cidr
  provider_credentials = var.provider_credentials
}
