output "worker_count" {
  value = var.k8s_worker_count
}

output "workers_ips" {
  value = { for name, r in proxmox_vm_qemu.k8s_workers : name => r.default_ipv4_address }
}

output "all_vm_ips" {
  value = merge(
    { for name, r in proxmox_vm_qemu.k8s_masters : name => r.default_ipv4_address },
    { for name, r in proxmox_vm_qemu.k8s_workers : name => r.default_ipv4_address },
    {
      # harbor    = proxmox_vm_qemu.harbor.default_ipv4_address,
      nfs_server= proxmox_vm_qemu.nfs_server.default_ipv4_address,
      # haproxy   = proxmox_vm_qemu.haproxy.default_ipv4_address,
    }
  )
}
