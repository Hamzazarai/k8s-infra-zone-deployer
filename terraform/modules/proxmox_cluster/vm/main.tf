resource "proxmox_vm_qemu" "vm" {
  for_each = { for vm in var.vms : vm.name => vm }

  name        = each.value.name
  target_node = var.proxmox_node
  clone       = var.base_template
  cores       = each.value.cpu
  memory      = each.value.ram
  sockets     = 1

  disk {
    size    = "${each.value.disk}G"
    type    = "scsi"
    storage = var.storage_pool
  }

  network {
    model  = "virtio"
    bridge = var.internal_bridge
  }

  dynamic "network" {
    for_each = each.value.dual_net == true ? [1] : []
    content {
      model  = "virtio"
      bridge = var.external_bridge
    }
  }

  ipconfig0 = "ip=${each.value.ip}/24,gw=${var.gateway}"
  sshkeys   = file("~/.ssh/id_rsa.pub")
  cloudinit_cdrom_storage = var.storage_pool
}
