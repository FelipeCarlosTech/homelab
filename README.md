# Homelab 🏠

A complete homelab infrastructure management system using Terraform, Ansible, and K3s for Kubernetes orchestration.

## Overview

This project provides a full infrastructure-as-code solution for managing a homelab environment. It leverages:
- **Terraform** for infrastructure provisioning
- **Ansible** for configuration management
- **K3s** as a lightweight Kubernetes distribution

## Components

### Terraform Modules

- **kubernetes_base**: Core Kubernetes infrastructure setup
- **storage**: Persistent volume management for Kubernetes
- **networking**: Network configuration including ingress controllers
- **security**: Security implementations like cert-manager and network policies

### Ansible Components

Automates server configuration and K3s deployment across the cluster.

## Prerequisites

- Terraform v1.0+
- Ansible v2.10+
- Linux/Unix-based systems for hosting K3s
- SSH access to all target machines
- Sufficient hardware resources (CPU/RAM/Storage)

## Installation

### Initial Setup

1. Clone the repository:
   ```
   git clone https://github.com/felipecarlos/homelab.git
   cd homelab
   ```

2. Configure Terraform variables:
   ```
   cp infrastructure/terraform/terraform.tfvars.example infrastructure/terraform/terraform.tfvars
   # Edit the terraform.tfvars file with your specific configuration
   ```

3. Set up Ansible inventory:
   ```
   cp ansible/inventory/hosts.example ansible/inventory/hosts
   # Edit the hosts file with your server details
   ```

### Deployment

1. Initialize and deploy infrastructure with Terraform:
   ```
   cd infrastructure/terraform
   terraform init
   terraform plan
   terraform apply
   ```

2. Configure servers with Ansible:
   ```
   cd ansible
   ansible-playbook main.yml
   ```

## Project Structure

```
homelab/
├── .gitignore                  # Git ignore patterns
├── README.md                   # This file
├── infrastructure/             # Infrastructure as code
│   └── terraform/              # Terraform configuration
│       ├── main.tf             # Main configuration file
│       ├── variables.tf        # Variable definitions
│       └── modules/            # Terraform modules
│           ├── kubernetes/     # K3s base setup
│           ├── storage/        # Storage configuration
│           ├── networking/     # Network setup
│           └── security/       # Security configuration
└── ansible/                    # Ansible configuration
    ├── inventory/              # Server inventory
    ├── roles/                  # Ansible roles
    ├── playbooks/              # Specific playbooks
    └── main.yml                # Main playbook
```

## Usage

### Terraform Management

Apply changes to specific modules:
```bash
terraform apply -target=module.storage
```

### Ansible Operations

Run specific tasks:
```bash
ansible-playbook playbooks/upgrade-k3s.yml
```

### K3s Cluster Management

Access your Kubernetes cluster:
```bash
export KUBECONFIG=/path/to/kubeconfig.yaml
kubectl get nodes
```

## Configuration

Key configuration files:
- `infrastructure/terraform/variables.tf`: Define infrastructure variables
- `ansible/inventory/group_vars/`: Group-specific variables
- `ansible/inventory/host_vars/`: Host-specific variables

## Troubleshooting

Common issues:
- Terraform state lock: `terraform force-unlock <ID>`
- Ansible connectivity: Check SSH keys and network connectivity
- K3s issues: Check logs with `journalctl -u k3s`

## Backup & Recovery

Backup strategies:
- Terraform: Regular state backup
- K3s: Etcd backup and snapshot management
- Data: Persistent volume backups

## Security Notes

- Sensitive values are stored in vault files
- Credentials are never committed to Git
- Regular updates are applied to all components