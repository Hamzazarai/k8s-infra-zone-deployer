locals {
  k8s_worker_names = [for i in range(1, var.worker_count + 1) : "k8s-worker-${i}"]
}

resource "proxmox_vm_qemu" "k8s_workers" {
  for_each    = toset(local.k8s_worker_names)
  vmid        = var.vm_resources["k8s_worker"].vmid + (tonumber(regex("[0-9]+$", each.key)) - 1)
  name        = each.key
  target_node = var.node
  clone       = var.vm_template
  full_clone  = true

  cpu {
    cores   = var.vm_resources["k8s_worker"].cpu
    sockets = 1
  }

  memory  = var.vm_resources["k8s_worker"].memory
  agent   = 1
  os_type = "cloud-init"

  disk {
    slot    = "scsi0"
    type    = "disk"
    storage = var.storage
    size    = var.vm_resources["k8s_worker"].disk
  }

  disk {
    type    = "cloudinit"
    storage = var.storage
    slot    = "ide2"
  }

  network {
    id     = 0
    model  = "virtio"
    bridge = "vmbr0"
  }

  scsihw     = "virtio-scsi-single"
  boot       = "c"
  ciuser     = "ubuntu"
  cipassword = "ubuntu123"
  sshkeys    = file("~/.ssh/id_rsa.pub")
  ipconfig0  = "ip=${var.vm_ips[each.key]}/24,gw=192.168.1.1"
  
  lifecycle {
    ignore_changes = all
  }
}
