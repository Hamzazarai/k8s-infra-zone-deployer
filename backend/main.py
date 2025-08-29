from fastapi import FastAPI, HTTPException
from models import VMConfig
from utils import generate_config_files, run_deployment
import json
from pathlib import Path
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI(title="K8s Autoscaler Backend", version="1.1")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:5173", "http://127.0.0.1:5173"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

VM_STATE_FILE = Path("./data/vm_state.json")

def save_vm_state(config: VMConfig):
    VM_STATE_FILE.parent.mkdir(exist_ok=True)
    # Update vm_ips with optional component IPs
    updated_vm_ips = config.vm_ips.copy()
    if config.enable_haproxy and config.haproxy_ip:
        updated_vm_ips["haproxy"] = config.haproxy_ip
    if config.enable_nfs and config.nfs_ip:
        updated_vm_ips["nfs"] = config.nfs_ip
    if config.enable_harbor and config.harbor_ip:
        updated_vm_ips["harbor"] = config.harbor_ip
    config_dict = config.dict()
    config_dict["vm_ips"] = updated_vm_ips
    with open(VM_STATE_FILE, "w") as f:
        json.dump(config_dict, f, indent=2)

def load_vm_state():
    if not VM_STATE_FILE.exists():
        return {}
    with open(VM_STATE_FILE) as f:
        return json.load(f)

@app.post("/deploy")
async def deploy(config: VMConfig):
    try:
        tfvars_path, hosts_ini_path = generate_config_files(config)
        # log_path = run_deployment(config)
        save_vm_state(config)
        return {
            "status": "success",
            "tfvars_file": tfvars_path,
            "hosts_ini_file": hosts_ini_path,
            # "log_file": log_path
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Deployment failed: {str(e)}")

@app.get("/vms")
async def list_vms():
    state = load_vm_state()
    if not state:
        return {"status": "empty", "message": "No VMs found"}
    return {
        "status": "success",
        "masters": {k: v for k, v in state.get("vm_ips", {}).items() if "master" in k},
        "workers": {k: v for k, v in state.get("vm_ips", {}).items() if "worker" in k},
        "others": {k: v for k, v in state.get("vm_ips", {}).items() if all(x not in k for x in ["master", "worker"])}
    }
