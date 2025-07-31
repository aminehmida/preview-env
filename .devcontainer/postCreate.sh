# /bin/bash

VERSION="0.21.0"
ARCH=$(dpkg --print-architecture)

# Function to execute on error
error_handler() {
    echo "An error occurred. Cleaning up..."
    # Remove the downloaded package if it exists
    if [ -f /tmp/jsonnet-go_${VERSION}_linux_${ARCH}.deb ]; then
        rm /tmp/jsonnet-go_${VERSION}_linux_${ARCH}.deb
    fi
    exit 1
}
trap 'error_handler' ERR

# Install jsonnet
wget https://github.com/google/go-jsonnet/releases/download/v${VERSION}/jsonnet-go_${VERSION}_linux_${ARCH}.deb -P /tmp
sudo dpkg -i /tmp/jsonnet-go_${VERSION}_linux_${ARCH}.deb

# Add aliases for kubectl and task
echo "alias k='kubectl'" >> ~/.bashrc
echo "alias t='task'" >> ~/.bashrc

# Enable autocompletion kubectl, terraform, and task
# Also enable autocompletion for the aliases
echo "source <(kubectl completion bash)" >> ~/.bashrc
echo "source <(task --completion bash)" >> ~/.bashrc
echo "complete -o default -F __start_kubectl k" >> ~/.bashrc
