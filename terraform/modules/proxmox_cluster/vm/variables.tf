variable "vms" {
  type = list(object({
    name     = string
    ip       = string
    cpu      = number
    ram      = number
    disk     = number
    dual_net = optional(bool)
  }))
}

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
