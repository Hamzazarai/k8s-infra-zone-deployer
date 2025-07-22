variable "provider_credentials" { 
    type = map(string)
    default = {
        url      = ""
        user     = ""
        password = ""
    }    
}
variable "zone_name" {
    default = "example"
}
variable "master_count" {
    default = 3
}
variable "master_cpu" {
    default = 2
}
variable "master_ram" {
    default = 8192
}
variable "master_disk" {
    default = 50
}

variable "worker_count" {
    default = 2
}
variable "worker_cpu" {
    default = 4
}
variable "worker_ram" {
    default = 16384
}
variable "worker_disk" {
    default = 100
}

variable "nat_network_cidr" {
    default = "10.0.0.0/24"
}

# Spécifiques à Proxmox
variable "proxmox_node" {
    default = "pve-node1"
}
variable "base_template" {
    default = "ubuntu-22.04-cloudinit"
}
variable "storage_pool" {
    default = "local-lvm"
}
variable "internal_bridge" {
    default = "vmbr1"
}
variable "external_bridge" {
    default = "vmbr0"
}
variable "gateway" {
    default = "10.0.0.1"
}
