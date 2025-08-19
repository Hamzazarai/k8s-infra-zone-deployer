from pathlib import Path
import subprocess

VM_CONFIG_PATH = Path("../terraform/vm_config.auto.tfvars")
HOSTS_INI_PATH = Path("../ansible/inventory/hosts.ini")

DEFAULT_USER = "ubuntu"
DEFAULT_PASS = "ubuntu123"

def write_tfvars(config):
    content = []

    # Counts
    content.append(f'k8s_master_count = {config.k8s_master_count}')
    content.append(f'k8s_worker_count = {config.k8s_worker_count}\n')

    # vm_ips
    content.append("vm_ips = {")
    for name, ip in config.vm_ips.items():
        content.append(f'  {name} = "{ip}"')
    content.append("}\n")

    # vm_resources
    content.append("vm_resources = {")
    for role, res in config.vm_resources.items():
        content.append(f'  {role} = {{')
        content.append(f'    vmid   = {res.vmid}')
        content.append(f'    cpu    = {res.cpu}')
        content.append(f'    memory = {res.memory}')
        content.append(f'    disk   = "{res.disk}"')
        content.append("  }")
    content.append("}")

    VM_CONFIG_PATH.write_text("\n".join(content))
    return str(VM_CONFIG_PATH)


def write_hosts_ini(config):
    lines = []

    lines.append("[kube_cluster:children]")
    lines.append("masters")
    lines.append("workers\n")

    if "nfs_server" in config.vm_ips:
        lines.append("[nfs]")
        lines.append(f'nfs-server ansible_host={config.vm_ips["nfs_server"]} '
                     f'ansible_user={DEFAULT_USER} ansible_ssh_pass={DEFAULT_PASS} ansible_become_pass={DEFAULT_PASS}\n')

    if "haproxy" in config.vm_ips:
        lines.append("[haproxy]")
        lines.append(f'haproxy ansible_host={config.vm_ips["haproxy"]} '
                     f'ansible_user={DEFAULT_USER} ansible_ssh_pass={DEFAULT_PASS} ansible_become_pass={DEFAULT_PASS}\n')

    if "monitoring" in config.vm_ips:
        lines.append("[monitoring]")
        lines.append(f'monitoring ansible_host={config.vm_ips["monitoring"]} '
                     f'ansible_user={DEFAULT_USER} ansible_ssh_pass={DEFAULT_PASS} ansible_become_pass={DEFAULT_PASS}\n')

    lines.append("[masters]")
    for i in range(1, config.k8s_master_count + 1):
        name = f"k8s-master-{i}"
        if name in config.vm_ips:
            lines.append(f'{name} ansible_host={config.vm_ips[name]} '
                         f'ansible_user={DEFAULT_USER} ansible_ssh_pass={DEFAULT_PASS} ansible_become_pass={DEFAULT_PASS}')
    lines.append("")

    lines.append("[workers]")
    for i in range(1, config.k8s_worker_count + 1):
        name = f"k8s-worker-{i}"
        if name in config.vm_ips:
            lines.append(f'{name} ansible_host={config.vm_ips[name]} '
                         f'ansible_user={DEFAULT_USER} ansible_ssh_pass={DEFAULT_PASS} ansible_become_pass={DEFAULT_PASS}')

    HOSTS_INI_PATH.write_text("\n".join(lines))
    return str(HOSTS_INI_PATH)


def generate_config_files(config):
    tfvars_path = write_tfvars(config)
    hosts_ini_path = write_hosts_ini(config)
    return tfvars_path, hosts_ini_path


def run_deployment():
    """Runs the deployment script and logs output."""
    log_file = Path("./logs/deploy.log")
    log_file.parent.mkdir(exist_ok=True)

    with open(log_file, "w") as f:
        process = subprocess.Popen(
            ["bash", "../scripts/run_deploy.sh"],
            stdout=f, stderr=subprocess.STDOUT
        )
        process.wait()

    return str(log_file)
