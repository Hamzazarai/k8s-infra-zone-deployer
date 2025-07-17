variable "provider_type" {} // "proxmox", "aws", "cloudstack"
variable "provider_credentials" { type = map(string) }
variable "zone_name" {}
variable "nat_network_cidr" {}

variable "master_count" {}
variable "master_cpu" {}
variable "master_ram" {}
variable "master_disk" {}

variable "worker_count" {}
variable "worker_cpu" {}
variable "worker_ram" {}
variable "worker_disk" {}
