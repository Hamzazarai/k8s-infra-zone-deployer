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
  default     = "192.168.1.0/24"
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
  type        = string
  default     = "20G"  # Default value can be overridden in auto.tfvars
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
  type        = string
  default     = "30G"  # Default value can be overridden in auto.tfvars
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

variable "master_vmid" {
  default = 300
}

variable "worker_vmid" {
  default = 400
}

variable "nfs_server_vmid" {
  default = 200
}

# HAProxy resources
variable "haproxy_cpu" {
  description = "vCPU count for HAProxy VM"
  type        = number
}

variable "haproxy_ram" {
  description = "RAM (MB) for HAProxy VM"
  type        = number
}

variable "haproxy_disk" {
  description = "Disk size (GB) for HAProxy VM"
  type        = string
  default     = "30G"  # Default value can be overridden in auto.tfvars
}

variable "enable_haproxy" {
  description = "Whether to deploy HAProxy VM"
  type        = bool
  default     = false
}

# NFS resources
variable "nfs_cpu" {
  description = "vCPU count for NFS server VM"
  type        = number
}

variable "nfs_ram" {
  description = "RAM (MB) for NFS server VM"
  type        = number
}

variable "nfs_disk" {
  description = "Disk size (GB) for NFS server VM"
  type        = string
  default     = "50G"  # Default value can be overridden in auto.tfvars
}

variable "enable_nfs" {
  description = "Whether to deploy NFS server VM"
  type        = bool
  default     = false
}

# Harbor resources
variable "harbor_cpu" {
  description = "vCPU count for Harbor registry VM"
  type        = number
}

variable "harbor_ram" {
  description = "RAM (MB) for Harbor registry VM"
  type        = number
}

variable "harbor_disk" {
  description = "Disk size (GB) for Harbor registry VM"
  type        = string
  default     = "30G"  # Default value can be overridden in auto.tfvars
}

variable "enable_harbor" {
  description = "Whether to deploy Harbor registry VM"
  type        = bool
  default     = false
}
