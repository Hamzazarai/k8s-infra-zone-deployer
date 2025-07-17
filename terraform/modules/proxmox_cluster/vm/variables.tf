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

variable "proxmox_node" {}
variable "base_template" {}
variable "storage_pool" {}
variable "internal_bridge" {}
variable "external_bridge" {}
variable "gateway" {}
