resource "proxmox_vm_qemu" "haproxy" {
  count       = var.enable_haproxy ? 1 : 0
  vmid        = var.haproxy_vmid
  name        = "haproxy"
  target_node = var.proxmox_node
  clone       = var.base_template
  full_clone  = true

  cpu {
    cores   = var.haproxy_cpu
    sockets = 1
  }

  memory  = var.haproxy_ram
  agent   = 1
  os_type = "cloud-init"

  disk {
    slot    = "scsi0"
    type    = "disk"
    storage = var.storage_pool
    size    = var.haproxy_disk
  }

  disk {
    type    = "cloudinit"
    storage = var.storage_pool
    slot    = "ide2"
  }

  network {
    id     = 0
    model  = "virtio"
    bridge = "vmbr0"
  }

  network {
    id     = 1
    model  = "virtio"
    bridge = "vmbr1"
  }

  scsihw     = "virtio-scsi-single"
  boot       = "c"
  ciuser     = var.cloud_init_user
  cipassword = var.cloud_init_password
  sshkeys    = file("~/.ssh/id_rsa.pub")

  ipconfig0 = "ip=dhcp"
  ipconfig1  = "ip=${var.vm_ips["haproxy"]}/24,gw=${var.gateway}"

  lifecycle {
    ignore_changes = all
  }
}
