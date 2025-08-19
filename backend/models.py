from pydantic import BaseModel, Field
from typing import Dict, Optional

class VMResource(BaseModel):
    cpu: int
    memory: int
    disk: str

class VMConfig(BaseModel):
    zone_name: str
    provider_type: str = "proxmox"

    proxmox_node: str
    # Coordonnées d'accès à l'API du provider
    api_url: str
    api_user: str
    api_password: str
    
    base_template: str
    storage_pool: str
    internal_bridge: str
    external_bridge: Optional[str] = None
    gateway: str

    nat_network_cidr: str

    master_count: int
    worker_count: int

    master_cpu: int
    master_ram: int
    master_disk: int

    worker_cpu: int
    worker_ram: int
    worker_disk: int

    ci_user: str = "ubuntu"
    ci_password: str = "ubuntu123"

    vm_ips: Dict[str, str] = Field(..., description="Nom => IP")
