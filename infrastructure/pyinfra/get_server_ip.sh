#!/bin/bash

# Script to get server IP from Terraform and update inventory
# Run this before executing pyinfra deployment

set -e

echo "Getting server IP from Terraform..."

# Change to terraform directory
cd "$(dirname "$0")/../terraform"

# Get the server IP
SERVER_IP=$(terraform output -raw server_ipv4)

if [ -z "$SERVER_IP" ]; then
    echo "Error: Could not get server IP from Terraform"
    echo "Make sure you have run 'terraform apply' first"
    exit 1
fi

echo "Server IP: $SERVER_IP"

# Update inventory with the actual IP
cd ../pyinfra

# Create a temporary inventory file with the actual IP
cat > inventory_with_ip.py << EOF
"""
PyInfra inventory configuration for Hetzner Kubernetes server
Auto-generated with actual server IP
"""

from pyinfra import host

# Define the server group with actual IP
kubernetes_servers = [
    "$SERVER_IP",
]

# Global configuration for all hosts
host.defaults = {
    "ssh_user": "root",
    "ssh_port": 22,
    "ssh_key": "~/.ssh/id_rsa",
}

# Host-specific configurations
@host.group(kubernetes_servers)
def k8s_config():
    """Configuration for Kubernetes servers"""
    host.data.k3s_version = "latest"
    host.data.k3s_channel = "stable"
    host.data.cluster_name = "preview-env"
    host.data.kubeconfig_path = "/etc/rancher/k3s/k3s.yaml"
    
    # k3s installation options
    host.data.k3s_options = [
        "--disable=traefik",
        "--disable=servicelb",
        "--write-kubeconfig-mode=644",
        "--cluster-cidr=10.42.0.0/16",
        "--service-cidr=10.43.0.0/16",
        "--node-external-ip=$SERVER_IP",
    ]
EOF

echo "Updated inventory_with_ip.py with server IP: $SERVER_IP"
echo ""
echo "Now you can run the deployment with:"
echo "  pyinfra inventory_with_ip.py deploy.py"
echo "or"
echo "  pyinfra inventory_with_ip.py full_deploy.py"
