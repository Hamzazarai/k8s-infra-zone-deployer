zone_name = "test"
provider_type = "proxmox"

provider_credentials = {
  url      = "https://192.168.1.17:8006/api2/json"
  user     = "root@pam"
  password = "sifast"
}

gateway = "10.0.0.1"

proxmox_node = "pve"
base_template = "temp-fix-image"
storage_pool = "local-lvm"
internal_bridge = "vmbr0"
external_bridge = "vmbr1"

master_count = 3
master_cpu = 4
master_ram = 8192
master_disk = "50G"

worker_count = 2
worker_cpu = 8
worker_ram = 16384
worker_disk = "100G"

haproxy_cpu = 4
haproxy_ram = 8192
haproxy_disk = "50G"

nfs_cpu = 2
nfs_ram = 8192
nfs_disk = "100G"

harbor_cpu = 2
harbor_ram = 8192
harbor_disk = "50G"

cloud_init_user = "ubuntu"
cloud_init_password = "ubuntu123"

enable_haproxy = true
enable_nfs = true
enable_harbor = true

vm_ips = {
  "master-1" = "10.0.0.11"
  "master-2" = "10.0.0.12"
  "master-3" = "10.0.0.13"
  "worker-1" = "10.0.0.21"
  "worker-2" = "10.0.0.22"
  "haproxy" = "10.0.0.88"
  "nfs" = "10.0.0.89"
  "harbor" = "10.0.0.77"
}