zone_name = "test"
provider_type = "proxmox"

provider_credentials = {
  url      = "https://192.168.1.17:8006/api2/json"
  user     = "root@pam"
  password = "sifast"
}

nat_network_cidr = "string"
gateway = "192.168.1.1/24"

proxmox_node = "pve"
base_template = "temp-fix-image"
storage_pool = "local-lvm"
internal_bridge = "brmo"
external_bridge = "brm1"

master_count = 1
master_cpu = 2
master_ram = 2048
master_disk = "20G"

worker_count = 1
worker_cpu = 1
worker_ram = 2048
worker_disk = "30G"

cloud_init_user = "ubuntu"
cloud_init_password = "ubuntu123"

vm_ips = {
  k8s-master-1 = "192.168.1.173"
  k8s-worker-1 = "192.168.1.174"
  nfs_server = "192.168.1.172"
}