output "worker_count" {
  value = var.worker_count
}

output "workers_ips" {
  value = { for name, r in proxmox_vm_qemu.k8s_workers : name => r.default_ipv4_address }
}

output "all_vm_ips" {
  value = merge(
    { for name, r in proxmox_vm_qemu.k8s_masters  : name => r.default_ipv4_address },
    { for name, r in proxmox_vm_qemu.k8s_workers  : name => r.default_ipv4_address },
    { for idx, r in proxmox_vm_qemu.harbor        : "harbor-${idx}"   => r.default_ipv4_address },
    { for idx, r in proxmox_vm_qemu.nfs_server    : "nfs-${idx}"      => r.default_ipv4_address },
    { for idx, r in proxmox_vm_qemu.haproxy       : "haproxy-${idx}"  => r.default_ipv4_address }
  )
}
