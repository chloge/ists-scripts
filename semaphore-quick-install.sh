#!/bin/bash

# Designed for Ubuntu or other apt-based distros.
# Tested on:
    # Ubuntu 22.08 LTS Server
    
if [ "$(id -u)" -ne 0 ]; then
  echo "This script must be run as root. Exiting."
  exit 1
fi

# Install Docker
sudo apt update
sudo apt install -y docker.io
sudo systemctl enable docker
sudo systemctl start docker

# Command to bring Semaphore container up
sudo docker run --name semaphore -p 3000:3000 -e SEMAPHORE_DB_DIALECT=bolt -e SEMAPHORE_ADMIN=admin -e SEMAPHORE_ADMIN_PASSWORD=changeme -e SEMAPHORE_ADMIN_NAME="Admin" -e SEMAPHORE_ADMIN_EMAIL=admin@localhost --restart=always -d semaphoreui/semaphore:v2.10.35

# Open port 3000 if requested
read -p "Would you like to open port 3000? Only allow this if you need the Semaphore web GUI accessable across the network (y/n): " open_port

if [ "$open_port" = "y" ]; then
    if command -v iptables > /dev/null 2>&1; then
        sudo iptables -I INPUT -p tcp --dport 3000 -j ACCEPT
        sudo iptables-save
        echo "Port 3000 opened"

    elif command -v nft > /dev/null 2>&1; then
        sudo nft add rule inet filter input tcp dport 3000 accept
        echo "Port 3000 opened"

    elif command -v firewall-cmd > /dev/null 2>&1; then
        sudo firewall-cmd --add-port=3000/tcp --permanent
        sudo firewall-cmd --reload
        echo "Port 3000 opened"

    elif command -v ufw > /dev/null 2>&1; then
        sudo ufw allow 3000/tcp
        sudo ufw reload
        echo "Port 3000 opened"

    else
        echo "No compatible firewall configuration tool present!"
    fi
else
    echo "No changes made"
fi

# Debug stuff
ip addr

echo "REMEMBER TO CHANGE SEMAPHORE ADMIN CREDENTIALS!!!!!!!!!"
