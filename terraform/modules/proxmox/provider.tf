terraform {
  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = "3.0.2-rc03"
    }
  }
}

provider "proxmox" {
  pm_api_url      = var.provider_credentials.url
  pm_user         = var.provider_credentials.user
  pm_password     = var.provider_credentials.password
  pm_tls_insecure = true
}
