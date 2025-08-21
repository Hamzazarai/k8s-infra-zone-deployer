locals {
  k8s_master_names = [for i in range(1, var.master_count + 1) : "k8s-master-${i}"]
}

resource "proxmox_vm_qemu" "k8s_masters" {
  for_each    = toset(local.k8s_master_names)
  vmid        = var.master_vmid + (tonumber(regex("[0-9]+$", each.key)) - 1)
  name        = each.key
  target_node = var.proxmox_node
  clone       = var.base_template
  full_clone  = true

  cpu {
    cores   = var.master_cpu
    sockets = 1
  }

  memory  = var.master_ram
  agent   = 1
  os_type = "cloud-init"

  disk {
    slot    = "scsi0"
    type    = "disk"
    storage = var.storage_pool
    size    = var.master_disk
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
  ipconfig0  = "ip=${var.vm_ips[each.key]}/24,gw=192.168.1.1"
  
  lifecycle {
    ignore_changes = all
  }
}
