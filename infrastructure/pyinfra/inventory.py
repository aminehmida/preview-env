"""
PyInfra inventory that dynamically gets server IP from Terraform
"""

import subprocess
import json
import os

from pyinfra import host

def get_terraform_output():
    """Get server IP from Terraform output"""
    try:
        # Change to terraform directory
        terraform_dir = os.path.join(os.path.dirname(__file__), '..', 'terraform')
        
        # Run terraform output command
        result = subprocess.run(
            ['terraform', 'output', '-json'],
            cwd=terraform_dir,
            capture_output=True,
            text=True,
            check=True
        )
        
        # Parse JSON output
        outputs = json.loads(result.stdout)
        server_ip = outputs['server_ip']['value']
        
        print(f"Retrieved server IP from Terraform: {server_ip}")
        return server_ip
        
    except subprocess.CalledProcessError as e:
        print(f"Error running terraform output: {e}")
        print("Make sure you have run 'terraform apply' first")
        raise
    except KeyError:
        print("Could not find 'server_ipv4' in terraform outputs")
        raise
    except Exception as e:
        print(f"Error getting server IP: {e}")
        raise

# Get server IP dynamically from Terraform
server_ip = get_terraform_output()
kubernetes_servers = [(server_ip, {"ssh_user": "root", "ssh_key": "../tmp/id_ed25519", "ssh_port": 22})]
