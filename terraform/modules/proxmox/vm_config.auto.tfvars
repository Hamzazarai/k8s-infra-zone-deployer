zone_name = "test"
provider_type = "proxmox"

provider_credentials = {
  url      = "https://192.168.1.17:8006/api2/json"
  user     = "root@pam"
  password = "sifast"
}

gateway = ""

proxmox_node = "pve"
base_template = "temp-fix-image"
storage_pool = "local-lvm"
internal_bridge = "vbbr0"

master_count = 1
master_cpu = 2
master_ram = 2048
master_disk = "50G"

worker_count = 1
worker_cpu = 1
worker_ram = 2048
worker_disk = "50G"

haproxy_cpu = 0
haproxy_ram = 0
haproxy_disk = "0"

nfs_cpu = 1
nfs_ram = 1024
nfs_disk = "100G"

harbor_cpu = 0
harbor_ram = 0
harbor_disk = "0"

cloud_init_user = "ubuntu"
cloud_init_password = "123"

enable_haproxy = false
enable_nfs = true
enable_harbor = false

vm_ips = {
  "master-1" = "192.168.1.173"
  "worker-1" = "192.168.1.174"
  "nfs" = "192.168.1.172"
}