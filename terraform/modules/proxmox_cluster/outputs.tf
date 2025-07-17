output "ansible_inventory" {
  value = {
    masters = [
      for vm in local.masters : {
        name = vm.name
        ip   = vm.ip
      }
    ]

    workers = [
      for vm in local.workers : {
        name = vm.name
        ip   = vm.ip
      }
    ]

    infra = {
      haproxy    = local.haproxy_ip
      nfs        = local.nfs_ip
      monitoring = local.monitoring_ip
    }
  }
}
