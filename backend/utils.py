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
    content.append(f'nat_network_cidr = "{config.nat_network_cidr}"')
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
    content.append(f'master_disk = {config.master_disk}\n')

    content.append(f'worker_count = {config.worker_count}')
    content.append(f'worker_cpu = {config.worker_cpu}')
    content.append(f'worker_ram = {config.worker_ram}')
    content.append(f'worker_disk = {config.worker_disk}\n')

    # Credentials cloud-init
    content.append(f'cloud_init_user = "{config.ci_user}"')
    content.append(f'cloud_init_password = "{config.ci_password}"\n')

    # IPs
    content.append("vm_ips = {")
    for name, ip in config.vm_ips.items():
        content.append(f'  {name} = "{ip}"')
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
    lines.append("workers\n")

    # NFS
    if "nfs_server" in config.vm_ips:
        lines.append("[nfs]")
        lines.append(f"nfs-server ansible_host={config.vm_ips['nfs_server']} "
                     f"ansible_user={user} ansible_ssh_pass={password} ansible_become_pass={password}\n")

    # HAProxy
    if "haproxy" in config.vm_ips:
        lines.append("[haproxy]")
        lines.append(f"haproxy ansible_host={config.vm_ips['haproxy']} "
                     f"ansible_user={user} ansible_ssh_pass={password} ansible_become_pass={password}\n")

    # Monitoring
    if "monitoring" in config.vm_ips:
        lines.append("[monitoring]")
        lines.append(f"monitoring ansible_host={config.vm_ips['monitoring']} "
                     f"ansible_user={user} ansible_ssh_pass={password} ansible_become_pass={password}\n")

    # Masters
    lines.append("[masters]")
    for i in range(1, config.master_count + 1):
        name = f"k8s-master-{i}"
        if name in config.vm_ips:
            lines.append(f"{name} ansible_host={config.vm_ips[name]} "
                         f"ansible_user={user} ansible_ssh_pass={password} ansible_become_pass={password}")
    lines.append("")

    # Workers
    lines.append("[workers]")
    for i in range(1, config.worker_count + 1):
        name = f"k8s-worker-{i}"
        if name in config.vm_ips:
            lines.append(f"{name} ansible_host={config.vm_ips[name]} "
                         f"ansible_user={user} ansible_ssh_pass={password} ansible_become_pass={password}")

    HOSTS_INI_PATH.write_text("\n".join(lines))
    return str(HOSTS_INI_PATH)



def generate_config_files(config: VMConfig):
    tfvars_path = write_tfvars(config)
    hosts_ini_path = write_hosts_ini(config)
    return tfvars_path, hosts_ini_path


def run_deployment():
    """Runs the deployment script and logs output."""
    log_file = Path("./logs/deploy.log")
    log_file.parent.mkdir(exist_ok=True)

    with open(log_file, "w") as f:
        process = subprocess.Popen(
            ["bash", "-c", "ANSIBLE_HOST_KEY_CHECKING=False ../scripts/run_deploy.sh"],
            stdout=f, stderr=subprocess.STDOUT
        )
        process.wait()

    return str(log_file)
