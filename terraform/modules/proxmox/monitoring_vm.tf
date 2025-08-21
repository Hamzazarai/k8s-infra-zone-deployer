# resource "proxmox_vm_qemu" "monitoring" {
#   vmid       = 206
#   name        = "monitoring"
#   target_node = var.node
#   clone       = var.vm_template
#   full_clone  = true

#   cpu {
#     cores   = 1
#     sockets = 1
#   }

#   memory  = 2048
#   agent   = 1
#   os_type = "cloud-init"

#   disk {
#     slot    = "scsi0"
#     type    = "disk"
#     storage = var.storage
#     size    = "10G"
#   }

#   disk {
#     type    = "cloudinit"
#     storage = var.storage
#     slot    = "ide2"
#   }

#   network {
#     id     = 0
#     model  = "virtio"
#     bridge = "vmbr0"
#   }

#   scsihw     = "virtio-scsi-single"
#   boot       = "c"
#   ciuser     = "ubuntu"
#   cipassword = "ubuntu123"
#   sshkeys    = file("~/.ssh/id_rsa.pub")
#   ipconfig0  = "ip=192.168.1.176/24,gw=192.168.1.1"
# 
#   lifecycle {
#     ignore_changes = all
#   }
# }
