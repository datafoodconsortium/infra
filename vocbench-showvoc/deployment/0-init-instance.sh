#!/bin/bash - 
#===============================================================================
#
#          FILE: init-instance.sh
# 
#         USAGE: ./init-instance.sh
# 
#   DESCRIPTION: Initializes a newly created Debian instance.
#                Tested with Debian 12.
# 
#        AUTHOR: Nicolas Broussard (nicolas@togetherfor.it)
#  ORGANIZATION: Together for it
#       CREATED: 11/15/2024 11:35:42 CET
#===============================================================================

set -euo pipefail                                  # https://bit.ly/eouxpipefail

# Update the system
echo "Updating system packages..."
sudo apt update

# Install locales, git, and remove apache2 if installed
sudo apt install locales-all git-all -y
sudo apt purge apache2 -y || true
sudo apt autoremove --purge -y

# Configure git to disable detached head warnings
git config --global advice.detachedHead false

# Check if Docker is already installed
if command -v docker &> /dev/null; then
    echo "✅ Docker is already installed: $(docker --version)"
else
    # Install prerequisites
    echo "Installing prerequisites..."
    sudo apt install -y ca-certificates curl gnupg lsb-release

    # Add Docker GPG key if it doesn't exist
    if [ ! -f /etc/apt/keyrings/docker.gpg ]; then
        echo "Adding Docker GPG key..."
        sudo mkdir -p /etc/apt/keyrings
        curl -fsSL https://download.docker.com/linux/debian/gpg \
            | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    fi

    # Add Docker repository if it doesn't exist
    if ! grep -q "https://download.docker.com/linux/debian" \
            /etc/apt/sources.list.d/docker.list 2>/dev/null; then
        echo "Adding Docker repository..."
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" \
            | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    fi

    # Install Docker
    echo "Installing Docker Engine and Docker Compose..."
    sudo apt update
    sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

    # Add user to the docker group
    nonroot_user=$(awk -F: '$3 >= 1000 && $3 < 60000 {print $1; exit}' /etc/passwd)
    echo "Adding user to the Docker group..."
    sudo usermod -aG docker $nonroot_user

    # Use GCR mirror of Docker Hub to prevent rate limiting errors with OVH
    echo '{ "registry-mirrors": ["https://mirror.gcr.io"] }' \
        | sudo tee /etc/docker/daemon.json
    sudo systemctl restart docker

    # Verify Docker installation
    echo "Verifying Docker installation..."
    docker --version && docker compose version
fi

echo "✅ Instance initialization complete!"
exit 0

