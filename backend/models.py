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
    api_url: str
    api_user: str
    api_password: str
    base_template: str
    storage_pool: str
    internal_bridge: str
    external_bridge: Optional[str] = None
    gateway: str
    master_count: int
    worker_count: int
    master_cpu: int
    master_ram: int
    master_disk: str

    worker_cpu: int
    worker_ram: int
    worker_disk: str

    ci_user: str = "ubuntu"
    ci_password: str = "ubuntu123"
    vm_ips: Dict[str, str] = Field(..., description="Nom => IP")
    enable_haproxy: bool = True
    haproxy_ip: Optional[str] = "10.0.0.88"
    haproxy_cpu: Optional[int] = 4
    haproxy_ram: Optional[int] = 8
    haproxy_disk: Optional[str] = 50
    enable_nfs: bool = True
    nfs_ip: Optional[str] = "10.0.0.89"
    nfs_cpu: Optional[int] = 2
    nfs_ram: Optional[int] = 8
    nfs_disk: Optional[str] = 100
    enable_harbor: bool = True
    harbor_ip: Optional[str] = "10.0.0.77"
    harbor_cpu: Optional[int] = 2
    harbor_ram: Optional[int] = 8
    harbor_disk: Optional[str] = 50
