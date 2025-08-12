resource "proxmox_vm_qemu" "haproxy" {
  vmid       = var.vm_resources["haproxy"].vmid
  name        = "haproxy"
  target_node = var.node
  clone       = var.vm_template
  full_clone  = true

  cpu {
    cores   = var.vm_resources["haproxy"].cpu
    sockets = 1
  }

  memory  = var.vm_resources["haproxy"].memory
  agent   = 1
  os_type = "cloud-init"

  disk {
    slot    = "scsi0"
    type    = "disk"
    storage = var.storage
    size    = var.vm_resources["haproxy"].disk
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
  ipconfig0  = "ip=${var.vm_ips["haproxy"]}/24,gw=192.168.1.1"
}
