variable "provider_type" {
    description = "Infrastructure provider to use (e.g., proxmox, cloudstack)"
    default     = "proxmox"
} 
variable "provider_credentials" { 
    description = "Map containing credentials for the provider"
    type        = map(string)
    default = {
        url      = "" 
        user     = ""
        password = ""
    } 
}
variable "zone_name" {
    description = "Name of the zone"
    default     = "example"
}
variable "nat_network_cidr" {
    description = "CIDR block for NATed private network"
    default     = "10.0.0.0/24"
}

variable "master_count" {
    description = "Number of Kubernetes master nodes"
    default     = 3
}
variable "master_cpu" {
    description = "Number of CPUs per master node"
    default     = 2
}
variable "master_ram" {
    description = "RAM (MB) per master node"
    default     = 8192
}
variable "master_disk" {
    description = "Disk size (GB) per master node"
    default     = 50
}

variable "worker_count" {
    description = "Number of Kubernetes worker nodes"
    default     = 2
}
variable "worker_cpu" {
    description = "Number of CPUs per worker node"
    default     = 4
}
variable "worker_ram" {
    description = "RAM (MB) per worker node"
    default     = 16384
}
variable "worker_disk" {
    description = "Disk size (GB) per worker node"
    default     = 100
}
