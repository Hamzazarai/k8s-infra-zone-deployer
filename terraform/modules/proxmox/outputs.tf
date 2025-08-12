output "haproxy_ip" {
  value = proxmox_vm_qemu.haproxy.default_ipv4_address
}

output "nfs_ip" {
  value = proxmox_vm_qemu.nfs_server.default_ipv4_address
}
