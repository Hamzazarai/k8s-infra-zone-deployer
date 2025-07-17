provider "proxmox" {
  pm_api_url = var.provider_credentials["url"]
  user       = var.provider_credentials["user"]
  password   = var.provider_credentials["password"]
  insecure   = true
}

module "vms" {
  source          = "./vm"
  vms             = local.vms
  proxmox_node    = var.proxmox_node
  base_template   = var.base_template
  storage_pool    = var.storage_pool
  internal_bridge = var.internal_bridge
  external_bridge = var.external_bridge
  gateway         = var.gateway
}
