#!/bin/bash
set -e

# Path to terraform directory
TF_DIR="terraform"

# Step 1: Get current worker count from Terraform state
cd $TF_DIR
CURRENT_COUNT=$(terraform output -raw worker_count 2>/dev/null || echo "1")

# Step 2: Increment count
NEW_COUNT=$((CURRENT_COUNT + 1))

echo "[INFO] Scaling workers: $CURRENT_COUNT -> $NEW_COUNT"

# Step 3: Update worker_count variable (using tfvars)
sed -i "s/^k8s_worker_count *=.*/k8s_worker_count = ${NEW_COUNT}/" vm_config.auto.tfvars

# Step 4: Apply Terraform changes
terraform apply -auto-approve

cd ..

# Step 5: Get the IP of the new worker from Terraform outputs

WORKER_NAME="k8s-worker-${NEW_COUNT}"

NEW_WORKER_IP=$(grep "$WORKER_NAME" terraform/vm_config.auto.tfvars | awk -F'"' '{print $2}')


echo "[INFO] New worker IP: $NEW_WORKER_IP"

echo "Waiting 90 seconds for VM to finish booting..."
sleep 90

# Step 6: Update Ansible inventory
echo "[INFO] Adding new worker to inventory..."
echo -e "\nk8s-worker-${NEW_COUNT} ansible_host=${NEW_WORKER_IP} ansible_user=ubuntu ansible_ssh_pass=ubuntu123 ansible_become_pass=ubuntu123" >> ansible/inventory/hosts.ini

# Step 7: Join the worker to the cluster
ansible-playbook -i ansible/inventory/hosts.ini ansible/k8s-setup.yml --limit k8s-worker-${NEW_COUNT}

echo "[SUCCESS] Worker $NEW_COUNT created and joined the cluster."