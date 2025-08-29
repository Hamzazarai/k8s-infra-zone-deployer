resource "proxmox_vm_qemu" "nfs_server" {
  count       = var.enable_nfs ? 1 : 0
  vmid        = var.nfs_server_vmid
  name        = "nfs-server"
  target_node = var.proxmox_node
  clone       = var.base_template
  full_clone  = true

  cpu {
    cores   = var.nfs_cpu
    sockets = 1
  }

  memory  = var.nfs_ram
  agent   = 1
  os_type = "cloud-init"

  disk {
    slot    = "scsi0"
    type    = "disk"
    storage = var.storage_pool
    size    = var.nfs_disk
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

  ipconfig1 = "ip=10.0.0.89/24,gw=10.0.0.1"
  ipconfig0  = "ip=${var.vm_ips["nfs"]}/24,gw=${var.gateway}"

  lifecycle {
    ignore_changes = all
  }
}
