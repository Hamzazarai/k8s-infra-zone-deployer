#!/usr/bin/env bash
set -euo pipefail

TFDIR="k8s-infra-zone-deployer/terraform"
OUTFILE="k8s-infra-zone-deployer/ansible/inventory/hosts.ini"

pushd "$TFDIR" >/dev/null

# ensure terraform init/plan has been run at least once
# get the all_vm_ips output as JSON -> name->ip
tf_json=$(terraform output -json all_vm_ips || echo "{}")

popd >/dev/null

python3 - <<PY
import json,sys,subprocess,os
tf_json = """$tf_json"""
if not tf_json or tf_json == "{}":
    print("No terraform output found for all_vm_ips; ensure Terraform has been applied.", file=sys.stderr)
    sys.exit(1)
ips = json.loads(tf_json)

# Build inventories — adjust hostnames and users to your defaults
masters = []
workers = []
for name,ip in ips.items():
    # identify masters/workers by prefix (k8s-master, k8s-worker)
    if name.startswith("k8s-master"):
        masters.append((name,ip))
    elif name.startswith("k8s-worker"):
        workers.append((name,ip))
    # keep haproxy, nfs etc. if desired

with open("${OUTFILE}", "w") as f:
    f.write("[masters]\n")
    for n,ip in masters:
        f.write(f"{n} ansible_host={ip} ansible_user=ubuntu ansible_ssh_pass=ubuntu123 ansible_become_pass=ubuntu123\n")
    f.write("\n[workers]\n")
    for n,ip in workers:
        f.write(f"{n} ansible_host={ip} ansible_user=ubuntu ansible_ssh_pass=ubuntu123 ansible_become_pass=ubuntu123\n")
    # kube_cluster group
    f.write("\n[kube_cluster:children]\nmasters\nworkers\n")
    # example nfs/haproxy groups if present
    if 'nfs_server' in ips:
        f.write("\n[nfs]\nnfs-server ansible_host={} ansible_user=ubuntu ansible_ssh_pass=ubuntu123 ansible_become_pass=ubuntu123\n".format(ips['nfs_server']))
print("Wrote ${OUTFILE}")
PY