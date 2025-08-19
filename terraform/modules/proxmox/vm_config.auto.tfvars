pm_api_url  = "https://192.168.1.17:8006/api2/json"
pm_user     = "root@pam"
pm_password = "sifast"
k8s_master_count = 1
k8s_worker_count = 1

vm_ips = {
  haproxy      = "192.168.1.172"
  k8s-master-1 = "192.168.1.173"
  k8s-worker-1 = "192.168.1.174"
  nfs_server   = "192.168.1.175"
  monitoring   = "192.168.1.176"
}

vm_resources = {
  haproxy = {
    vmid   = 202
    cpu    = 1
    memory = 2048
    disk   = "20G"
  }

  k8s_master = {
    vmid   = 203
    cpu    = 2
    memory = 2048
    disk   = "32G"
  }

  k8s_worker = {
    vmid   = 204
    cpu    = 1
    memory = 2048
    disk   = "40G"
  }

  nfs_server = {
    vmid   = 205
    cpu    = 1
    memory = 1024
    disk   = "32G"
  }

  monitoring = {
    vmid   = 206
    cpu    = 1
    memory = 2048
    disk   = "10G"
  }
}
