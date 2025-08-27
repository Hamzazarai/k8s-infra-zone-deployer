!/usr/bin/env bash
set -e

echo "Step 0: Terraform init"
cd ../terraform/modules/proxmox
terraform init
echo "Done with Terraform init."

echo "Step 1: Terraform apply"
terraform apply -auto-approve
# terraform plan
echo "Done with Terraform apply."

echo "Waiting 60 seconds for VMs to finish booting..."
sleep 60

echo "Step 2: Run Ansible deploy.yml"
cd ../../../ansible
ansible-playbook -i inventory/hosts.ini deploy.yml
echo "Done with Ansible deploy.yml."
