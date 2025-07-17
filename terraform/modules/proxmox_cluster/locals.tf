locals {
  haproxy_ip    = cidrhost(var.nat_network_cidr, 100)
  nfs_ip        = cidrhost(var.nat_network_cidr, 88)
  monitoring_ip = cidrhost(var.nat_network_cidr, 77)

  master_subnet = cidrsubnet(var.nat_network_cidr, 8, 10)
  worker_subnet = cidrsubnet(var.nat_network_cidr, 8, 20)

  masters = [
    for i in range(var.master_count) : {
      name = "master-${i + 1}"
      ip   = cidrhost(local.master_subnet, i + 1)
      cpu  = var.master_cpu
      ram  = var.master_ram
      disk = var.master_disk
    }
  ]

  workers = [
    for i in range(var.worker_count) : {
      name = "worker-${i + 1}"
      ip   = cidrhost(local.worker_subnet, i + 1)
      cpu  = var.worker_cpu
      ram  = var.worker_ram
      disk = var.worker_disk
    }
  ]

  infra = [
    {
      name     = "haproxy"
      ip       = local.haproxy_ip
      cpu      = 2
      ram      = 2048
      disk     = 20
      dual_net = true
    },
    {
      name = "nfs"
      ip   = local.nfs_ip
      cpu  = 2
      ram  = 4096
      disk = 100
    },
    {
      name = "monitoring"
      ip   = local.monitoring_ip
      cpu  = 4
      ram  = 6144
      disk = 80
    }
  ]

  vms = concat(local.infra, local.masters, local.workers)
}
