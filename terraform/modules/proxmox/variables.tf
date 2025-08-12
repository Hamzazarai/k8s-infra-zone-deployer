variable "node"        { default = "pve" }
variable "vm_template" { default = "temp-fix-image" }
variable "storage"     { default = "local-lvm" }

variable "k8s_master_count" {
  description = "Number of Kubernetes master nodes"
  type        = number
}

variable "k8s_worker_count" {
  description = "Number of Kubernetes worker nodes"
  type        = number
}

variable "vm_ips" {
  description = "Map of static IP addresses for each VM"
  type        = map(string)
}

variable "vm_resources" {
  description = "Map of VM resource definitions"
  type = map(object({
    vmid   = number
    cpu    = number
    memory = number
    disk   = string
  }))
}
