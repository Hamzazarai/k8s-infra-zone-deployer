k8s_master_count = 1
k8s_worker_count = 1

vm_ips = {
  k8s-master-1 = "192.168.1.173"
  k8s-worker-1 = "192.168.1.174"
  nfs_server = "192.168.1.172"
}

vm_resources = {
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
    vmid   = 202
    cpu    = 1
    memory = 1024
    disk   = "32G"
  }
}