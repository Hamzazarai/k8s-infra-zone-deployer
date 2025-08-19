!/usr/bin/env bash
set -e

echo "Step 0: Terraform init"
cd terraform/
terraform init
echo "Done with Terraform init."

echo "Step 1: Terraform apply"
terraform apply -auto-approve
echo "Done with Terraform apply."

echo "Waiting 60 seconds for VMs to finish booting..."
sleep 60

echo "Step 2: Run Ansible k8s-setup.yml"
cd ../ansible
ansible-playbook -i inventory/hosts.ini k8s-setup.yml
echo "Done with k8s-setup.yml."

echo "Step 3: Run Ansible helm_monitoring.yml"
ansible-playbook -i inventory/hosts.ini helm_monitoring.yml
echo "Done with helm_monitoring.yml."
