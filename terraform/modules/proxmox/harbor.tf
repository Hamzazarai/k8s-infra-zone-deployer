resource "proxmox_vm_qemu" "harbor" {
  count       = var.enable_harbor ? 1 : 0
  vmid        = var.harbor_vmid
  name        = "harbor"
  target_node = var.proxmox_node
  clone       = var.base_template
  full_clone  = true

  cpu {
    cores   = var.harbor_cpu
    sockets = 1
  }

  memory  = var.harbor_ram
  agent   = 1
  os_type = "cloud-init"

  disk {
    slot    = "scsi0"
    type    = "disk"
    storage = var.storage_pool
    size    = var.harbor_disk
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

  scsihw     = "virtio-scsi-single"
  boot       = "c"
  ciuser     = var.cloud_init_user
  cipassword = var.cloud_init_password
  sshkeys    = file("~/.ssh/id_rsa.pub")
  ipconfig0  = "ip=${var.vm_ips["harbor"]}/24,gw=192.168.1.1"

  lifecycle {
    ignore_changes = all
  }
}
