from pydantic import BaseModel, Field
from typing import Dict

class VMResource(BaseModel):
    vmid: int = Field(..., description="VM ID in Proxmox")
    cpu: int = Field(..., description="Number of vCPUs")
    memory: int = Field(..., description="Memory in MB")
    disk: str = Field(..., description="Disk size, e.g., '32G'")

class VMConfig(BaseModel):
    k8s_master_count: int = Field(..., ge=1, description="Number of master nodes")
    k8s_worker_count: int = Field(..., ge=0, description="Number of worker nodes")
    vm_ips: Dict[str, str] = Field(
        ..., 
        description="Mapping of VM name to IP address"
    )
    vm_resources: Dict[str, VMResource] = Field(
        ..., 
        description="Resource allocation for each VM type"
    )
