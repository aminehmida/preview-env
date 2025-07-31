#!/usr/bin/env python3
import os
from pyinfra.operations import server, apt, files, python
from pyinfra import host, logger
from pyinfra.facts.systemd import SystemdEnabled
from io import StringIO


# Update system packages
apt.update(
    name="Update package lists",
)

# Install curl (needed for k3s installation)
apt.packages(
    name="Install curl",
    packages=["curl"],
)
    
# Install k3s if not already installed

k3s_installed = host.get_fact(SystemdEnabled, services=["k3s"])["k3s.service"]
if not k3s_installed:
    logger.info("k3s is not installed, proceeding with installation.")
    server.shell(
        name="Install k3s",
        commands=[
            "curl -sfL https://get.k3s.io | sh -"
        ],
        _sudo=True,
    )
else:
    logger.info("k3s is already installed, skipping installation.")

# Create directory for k3s registries configuration
server.shell(
    name="Create k3s configuration directory",
    commands=[
        "mkdir -p /etc/rancher/k3s"
    ],
    _sudo=True,
)

# Get registry configuration from environment variables
registry_url = os.environ.get('REGISTRY_URL')
registry_username = os.environ.get('REGISTRY_USERNAME')
registry_password = os.environ.get('REGISTRY_PASSWORD')

if not all([registry_url, registry_username, registry_password]):
    raise ValueError("Missing required environment variables: REGISTRY_URL, REGISTRY_USERNAME, REGISTRY_PASSWORD")

# Create registries.yaml content
registries_content = f"""mirrors:
  {registry_url}:
    endpoint:
      - https://{registry_url}/v2
configs:
  {registry_url}:
    auth:
      username: {registry_username}
      password: {registry_password}
"""

# Create the registries.yaml file
files.put(
    name="Create k3s registries configuration",
    src=StringIO(registries_content),
    dest="/etc/rancher/k3s/registries.yaml",
    mode="644",
    user="root",
    group="root",
    _sudo=True,
)

# Wait for k3s to start and restart it to pick up registry configuration
server.shell(
    name="Enable and restart k3s service",
    commands=[
        "systemctl enable k3s",
        "systemctl restart k3s",
        "sleep 30"  # Give k3s time to restart with new registry config
    ],
    _sudo=True,
)
    
# Check if k3s is running
server.shell(
    name="Check k3s status",
    commands=[
        "systemctl status k3s",
        "k3s kubectl get nodes"
    ],
    _sudo=True,
)

# Upload traefik helm chart configuration
# Get the email for Let's Encrypt from environment variables
letsencrypt_email = os.environ.get('LETSENCRYPT_EMAIL')
if not letsencrypt_email:
    raise ValueError("Missing required environment variable: LETSENCRYPT_EMAIL")
files.template(
    name="Upload traefik helm chart configuration",
    src="./templates/traefik-config.yaml.j2",
    dest="/var/lib/rancher/k3s/server/manifests/traefik-config.yaml",
    mode="644",
    user="root",
    group="root",
    _sudo=True,
    letsencrypt_email=letsencrypt_email
)

# Download kubeconfig file to ../tmp/kubeconfig
# kubeconfig_path = os.path.join('..', 'tmp', 'kubeconfig')
kubeconfig_path = "../tmp/kubeconfig"
# Delete the existing kubeconfig file if it exists
if os.path.exists(kubeconfig_path):
    os.remove(kubeconfig_path)

files.get(
    name="Download kubeconfig file",
    src="/etc/rancher/k3s/k3s.yaml",
    dest=kubeconfig_path,
)

# Replace 127.0.0.1 with the actual server IP in kubeconfig
# Only execute if the kubeconfig file was changed and the server name is available and the file exists
server_name = host.name

def replace_kubeconfig_ip():
    if not os.path.exists(kubeconfig_path):
        logger.error(f"Kubeconfig file does not exist at {kubeconfig_path}")
        return False
    with open(kubeconfig_path, 'r') as file:
        kubeconfig_content = file.read()
        kubeconfig_content = kubeconfig_content.replace('127.0.0.1', server_name)
        with open(kubeconfig_path, 'w') as file:
            file.write(kubeconfig_content)
            logger.info(f"Updated kubeconfig file at {kubeconfig_path} with server IP {server_name}")

python.call(
    name="Replace IP in kubeconfig",
    function=replace_kubeconfig_ip,
)