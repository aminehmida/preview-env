"""
Full k3s deployment with all components
"""

from pyinfra import host
from pyinfra.operations import server, files, apt
from pyinfra.api import deploy

# Import individual deployment modules
from deployments.k3s import (
    install_k3s, 
    configure_k3s, 
    install_k8s_tools, 
    setup_ingress, 
    setup_monitoring,
    create_preview_namespace
)


@deploy("Complete k3s setup")
def deploy_complete_k3s():
    """Complete k3s deployment with all components"""
    
    print("Starting complete k3s deployment...")
    
    # 1. System preparation
    apt.update(
        name="Update package lists",
        cache_time=3600,
    )
    
    apt.packages(
        name="Install system dependencies",
        packages=[
            "curl",
            "wget",
            "vim",
            "htop",
            "unzip",
            "ca-certificates",
            "gnupg",
            "lsb-release",
            "apt-transport-https",
            "software-properties-common",
            "bash-completion",
        ],
        update=True,
    )
    
    # 2. Install k3s
    install_k3s()
    
    # 3. Configure k3s
    configure_k3s()
    
    # 4. Install additional tools
    install_k8s_tools()
    
    # 5. Setup ingress controller
    setup_ingress()
    
    # 6. Setup monitoring
    setup_monitoring()
    
    # 7. Create preview environment namespace
    create_preview_namespace()
    
    # 8. Final verification
    server.shell(
        name="Verify cluster status",
        commands=[
            "k3s kubectl get nodes -o wide",
            "k3s kubectl get pods -A",
            "k3s kubectl cluster-info"
        ],
        _sudo=True,
    )
    
    print("k3s deployment completed successfully!")


if __name__ == "__main__":
    print("Run this with: pyinfra inventory.py full_deploy.py")
