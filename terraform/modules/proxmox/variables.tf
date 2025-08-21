# Zone and provider type
variable "zone_name" {
  description = "Name of the deployment zone"
  type        = string
}

variable "provider_type" {
  description = "Infrastructure provider (e.g., proxmox, cloudstack)"
  type        = string
}

# Provider credentials
variable "provider_credentials" {
  description = "Credentials for the infrastructure provider"
  type = object({
    url      = string
    user     = string
    password = string
  })
}

# Networking
variable "nat_network_cidr" {
  description = "NAT network CIDR for the cluster"
  type        = string
}

variable "gateway" {
  description = "Gateway IP address for the cluster"
  type        = string
}

variable "internal_bridge" {
  description = "Internal bridge for VM communication"
  type        = string
}

variable "external_bridge" {
  description = "External bridge for internet access"
  type        = string
}

# Proxmox specific
variable "proxmox_node" {
  description = "Proxmox node name"
  type        = string
}

variable "base_template" {
  description = "Base VM template name"
  type        = string
}

variable "storage_pool" {
  description = "Proxmox storage pool"
  type        = string
}

# VM counts
variable "master_count" {
  description = "Number of master nodes"
  type        = number
}

variable "worker_count" {
  description = "Number of worker nodes"
  type        = number
}

# VM resources
variable "master_cpu" {
  description = "vCPU count for master nodes"
  type        = number
}

variable "master_ram" {
  description = "RAM (MB) for master nodes"
  type        = number
}

variable "master_disk" {
  description = "Disk size (GB) for master nodes"
  type        = number
}

variable "worker_cpu" {
  description = "vCPU count for worker nodes"
  type        = number
}

variable "worker_ram" {
  description = "RAM (MB) for worker nodes"
  type        = number
}

variable "worker_disk" {
  description = "Disk size (GB) for worker nodes"
  type        = number
}

# Cloud-init
variable "cloud_init_user" {
  description = "Cloud-init default user"
  type        = string
}

variable "cloud_init_password" {
  description = "Cloud-init default password"
  type        = string
}

# IP addresses
variable "vm_ips" {
  description = "Map of static IPs for all cluster VMs"
  type        = map(string)
}
