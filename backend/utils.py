from pathlib import Path
import subprocess
from models import VMConfig

VM_CONFIG_PATH = Path("../terraform/modules/proxmox/vm_config.auto.tfvars")
HOSTS_INI_PATH = Path("../ansible/inventory/hosts.ini")

def write_tfvars(config: VMConfig):
    content = []

    # Général
    content.append(f'zone_name = "{config.zone_name}"')
    content.append(f'provider_type = "{config.provider_type}"\n')

    # Credentials Proxmox
    content.append("provider_credentials = {")
    content.append(f'  url      = "{config.api_url}"')
    content.append(f'  user     = "{config.api_user}"')
    content.append(f'  password = "{config.api_password}"')
    content.append("}\n")

    # Réseau
    content.append(f'gateway = "{config.gateway}"\n')

    # Proxmox infra
    content.append(f'proxmox_node = "{config.proxmox_node}"')
    content.append(f'base_template = "{config.base_template}"')
    content.append(f'storage_pool = "{config.storage_pool}"')
    content.append(f'internal_bridge = "{config.internal_bridge}"')
    if config.external_bridge:
        content.append(f'external_bridge = "{config.external_bridge}"')
    content.append("")

    # Ressources
    content.append(f'master_count = {config.master_count}')
    content.append(f'master_cpu = {config.master_cpu}')
    content.append(f'master_ram = {config.master_ram}')
    content.append(f'master_disk = "{config.master_disk}"\n')

    content.append(f'worker_count = {config.worker_count}')
    content.append(f'worker_cpu = {config.worker_cpu}')
    content.append(f'worker_ram = {config.worker_ram}')
    content.append(f'worker_disk = "{config.worker_disk}"\n')

    # Optional component resources
    content.append(f'haproxy_cpu = {config.haproxy_cpu if config.enable_haproxy else 0}')
    content.append(f'haproxy_ram = {config.haproxy_ram if config.enable_haproxy else 0}')
    content.append(f'haproxy_disk = "{config.haproxy_disk if config.enable_haproxy else 0}"\n')
    content.append(f'nfs_cpu = {config.nfs_cpu if config.enable_nfs else 0}')
    content.append(f'nfs_ram = {config.nfs_ram if config.enable_nfs else 0}')
    content.append(f'nfs_disk = "{config.nfs_disk if config.enable_nfs else 0}"\n')
    content.append(f'harbor_cpu = {config.harbor_cpu if config.enable_harbor else 0}')
    content.append(f'harbor_ram = {config.harbor_ram if config.enable_harbor else 0}')
    content.append(f'harbor_disk = "{config.harbor_disk if config.enable_harbor else 0}"\n')

    # Credentials cloud-init
    content.append(f'cloud_init_user = "{config.ci_user}"')
    content.append(f'cloud_init_password = "{config.ci_password}"\n')

    # Optional components
    content.append(f'enable_haproxy = {str(config.enable_haproxy).lower()}')
    content.append(f'enable_nfs = {str(config.enable_nfs).lower()}')
    content.append(f'enable_harbor = {str(config.enable_harbor).lower()}\n')

    # IPs
    content.append("vm_ips = {")
    for name, ip in config.vm_ips.items():
        content.append(f'  "{name}" = "{ip}"')
    content.append("}")

    VM_CONFIG_PATH.write_text("\n".join(content))
    return str(VM_CONFIG_PATH)

def write_hosts_ini(config: VMConfig):
    lines = []

    user = config.ci_user
    password = config.ci_password

    # Cluster groups
    lines.append("[kube_cluster:children]")
    lines.append("masters")
    lines.append("workers")
    lines.append("")  # blank line

    # NFS
    if config.enable_nfs and "nfs" in config.vm_ips:
        lines.append("[nfs]")
        lines.append(f"nfs ansible_host={config.vm_ips['nfs']} "
                     f"ansible_user={user} ansible_ssh_pass={password} ansible_become_pass={password}")
        lines.append("")

    # HAProxy
    if config.enable_haproxy and "haproxy" in config.vm_ips:
        lines.append("[haproxy]")
        lines.append(f"haproxy ansible_host={config.vm_ips['haproxy']} "
                     f"ansible_user={user} ansible_ssh_pass={password} ansible_become_pass={password}")
        lines.append("")

    # Harbor
    if config.enable_harbor and "harbor" in config.vm_ips:
        lines.append("[harbor]")
        lines.append(f"harbor ansible_host={config.vm_ips['harbor']} "
                     f"ansible_user={user} ansible_ssh_pass={password} ansible_become_pass={password}")
        lines.append("")

    # Masters
    masters = [(key, ip) for key, ip in config.vm_ips.items() if key.startswith("master-")]
    masters.sort(key=lambda x: int(x[0].split("-")[1]))  # ensure master-1, master-2 order

    lines.append("[masters]")
    for key, ip in masters:
        lines.append(f"{key} ansible_host={ip} "
                     f"ansible_user={user} ansible_ssh_pass={password} ansible_become_pass={password}")
    lines.append("")

    # Split master_init and master_join
    if masters:
        lines.append("[master_init]")
        key, ip = masters[0]  # first master
        lines.append(f"{key} ansible_host={ip} "
                     f"ansible_user={user} ansible_ssh_pass={password} ansible_become_pass={password}")
        lines.append("")

        if len(masters) > 1:
            lines.append("[master_join]")
            for key, ip in masters[1:]:
                lines.append(f"{key} ansible_host={ip} "
                             f"ansible_user={user} ansible_ssh_pass={password} ansible_become_pass={password}")
            lines.append("")

    # Workers
    lines.append("[workers]")
    for key, ip in config.vm_ips.items():
        if key.startswith("worker-"):
            lines.append(f"{key} ansible_host={ip} "
                         f"ansible_user={user} ansible_ssh_pass={password} ansible_become_pass={password}")

    # Write to file
    HOSTS_INI_PATH.write_text("\n".join(lines))
    return str(HOSTS_INI_PATH)





def generate_config_files(config: VMConfig):
    tfvars_path = write_tfvars(config)
    hosts_ini_path = write_hosts_ini(config)
    return tfvars_path, hosts_ini_path

def run_deployment(config: VMConfig):
    """Runs the deployment script and logs output."""
    log_file = Path("./logs/deploy.log")
    log_file.parent.mkdir(exist_ok=True)

    with open(log_file, "w") as f:
        # f.write("Starting deployment...\n")
        # if config.enable_haproxy:
        #     f.write("Deploying HAProxy Load Balancer...\n")
        # if config.enable_nfs:
        #     f.write("Deploying NFS Storage...\n")
        # if config.enable_harbor:
        #     f.write("Deploying Harbor Registry...\n")
        # f.write("Running Terraform and Ansible deployment...\n")
        process = subprocess.Popen(
            ["bash", "-c", "ANSIBLE_HOST_KEY_CHECKING=False ../scripts/run_deploy.sh"],
            stdout=f, stderr=subprocess.STDOUT
        )
        process.wait()

    return str(log_file)

    
    
