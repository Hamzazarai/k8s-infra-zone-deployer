variable "provider_credentials" { type = map(string) }
variable "zone_name" {}
variable "master_count" {}
variable "master_cpu" {}
variable "master_ram" {}
variable "master_disk" {}

variable "worker_count" {}
variable "worker_cpu" {}
variable "worker_ram" {}
variable "worker_disk" {}

variable "nat_network_cidr" {}

# Spécifiques à Proxmox
variable "proxmox_node" {}
variable "base_template" {}
variable "storage_pool" {}
variable "internal_bridge" {}
variable "external_bridge" {}
variable "gateway" {}
