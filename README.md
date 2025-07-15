# k8s-infra-zone-deployer


```markdown
# Kubernetes Infrastructure Zone Deployer

This project provides a user-friendly web interface to dynamically deploy Kubernetes infrastructure zones on a Proxmox virtualized environment. It combines Terraform and Ansible to fully automate infrastructure provisioning and configuration.

##  Project Overview

Users can access a web application to create new Kubernetes zones by specifying:

- Zone name
- Private NAT subnet
- Number and resources for Kubernetes masters
- Number and resources for Kubernetes workers

Terraform handles the provisioning of virtual machines (VMs), IP address assignments, and network setup. Ansible automates the deployment and configuration of Kubernetes, JupyterHub, NFS, Harbor, and monitoring tools (Prometheus + Grafana).

## 🛠 Technologies Used

- Terraform (with Proxmox provider)
- Ansible
- Proxmox VE (virtual environment)
- Python (FastAPI or Flask backend)
- JupyterHub (deployed in HA)
- HAProxy (load balancer with dual interfaces)
- NFS (persistent storage)
- Harbor (image registry)
- Prometheus & Grafana (monitoring)
- Manus (UI prototyping)

##  Features

- Web form interface for infrastructure configuration
- IP addresses assigned automatically by Terraform
- Support for multiple zones (multi-tenant)
- Dynamic generation of Terraform variables from user input
- Phase 1: Terraform provisioning (VMs, networks, storage)
- Phase 2 (optional): Ansible deployment of services
- Real-time logs and deployment status feedback

##  Directory Structure

```

k8s-infra-zone-deployer/
├── frontend/                # Web interface (React, etc.)
├── backend/                 # Flask or FastAPI API
│   ├── templates/
│   ├── terraform\_generator.py
│   ├── ansible\_runner.py
│   └── routes.py
├── terraform/
│   ├── main.tf
│   ├── modules/
│   ├── variables.tf
│   └── terraform.tfvars.json (generated)
├── ansible/
│   ├── inventory/
│   ├── site.yml
│   └── roles/
└── README.md

```

##  How It Works

1. User fills in the web form:
   - Zone name
   - NAT IP range (e.g. 10.0.0.0/24)
   - Number of masters/workers
   - RAM, CPU, disk per node type

2. Backend generates:
   - terraform.tfvars.json
   - IP addresses for each VM

3. Terraform is executed:
   - HAProxy VM (dual interface)
   - NFS VM (10.0.0.88)
   - Harbor + monitoring VM (10.0.0.77)
   - Masters: 10.0.10.n
   - Workers: 10.0.20.m

4. (Optional) Ansible configures:
   - Kubernetes cluster
   - JupyterHub
   - NFS shares
   - Harbor, Prometheus, Grafana

##  Prerequisites

- Proxmox VE with API access
- Terraform CLI
- Ansible CLI
- Python 3.10+ and FastAPI/Flask
- SSH keys for automation
- Configured Proxmox templates for Ubuntu-based VMs



##  License

MIT License – Feel free to use, modify and improve this project.
```
