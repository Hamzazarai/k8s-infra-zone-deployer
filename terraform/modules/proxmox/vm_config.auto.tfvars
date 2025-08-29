zone_name = "test"
provider_type = "proxmox"

provider_credentials = {
  url      = "https://10.110.188.59:8006/api2/json"
  user     = "root@pam"
  password = "root123"
}

gateway = "10.110.188.1"

proxmox_node = "proxmox"
base_template = "ubuntu-template"
storage_pool = "local-lvm"
internal_bridge = "vmbr0"
external_bridge = "vmbr0"

master_count = 3
master_cpu = 3
master_ram = 4096
master_disk = "50G"

worker_count = 2
worker_cpu = 4
worker_ram = 8192
worker_disk = "50G"

haproxy_cpu = 2
haproxy_ram = 4096
haproxy_disk = "50G"

nfs_cpu = 2
nfs_ram = 8192
nfs_disk = "100G"

harbor_cpu = 2
harbor_ram = 8192
harbor_disk = "50G"

cloud_init_user = "ubuntu"
cloud_init_password = "123"

enable_haproxy = true
enable_nfs = true
enable_harbor = true

vm_ips = {
  "master-1" = "10.110.188.11"
  "master-2" = "10.110.188.12"
  "master-3" = "10.110.188.13"
  "worker-1" = "10.110.188.21"
  "worker-2" = "10.110.188.22"
  "haproxy" = "10.110.188.99"
  "nfs" = "10.110.188.80"
  "harbor" = "10.110.188.77"
}