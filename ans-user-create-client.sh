#!/bin/bash

# Check if the script is being run as root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root"
    exit 1
fi

# Ensure SSH is installed
if ! command -v ssh &> /dev/null; then
    echo "SSH is not installed. Installing SSH..."

    if command -v apt-get &> /dev/null; then
        sudo apt-get update
        sudo apt-get install -y openssh-server
    elif command -v dnf &> /dev/null; then
        sudo dnf install -y openssh-server
    elif command -v yum &> /dev/null; then
        sudo yum install -y openssh-server
    else
        echo "Unsupported package manager. Please install SSH manually."
        exit 1
    fi
fi

# Check if the user "lemongreen" already exists
if id "lemongreen" &>/dev/null; then
    echo "User 'lemongreen' already exists. Exiting the script."
    exit 1
fi

# Create a new user named "lemongreen"
sudo adduser lemongreen

# Ensure the .ssh directory exists
sudo mkdir -p /home/lemongreen/.ssh
sudo chown lemongreen:lemongreen /home/lemongreen/.ssh
sudo chmod 700 /home/lemongreen/.ssh

# Disable password authentication locally
sudo passwd -l lemongreen

# Prompt for the allowed remote host
read -p "Enter the remote host IP address to allow logins from: " allowed_host

# Create a custom SSHD configuration for the "lemongreen" user
echo "Match User lemongreen" | sudo tee /etc/ssh/sshd_config.d/lemongreen.conf
echo "    AllowUsers lemongreen@${allowed_host}" | sudo tee -a /etc/ssh/sshd_config.d/lemongreen.conf

# Ensure password authentication remains enabled for remote login by modifying sshd_config
sudo sed -i '/^#PasswordAuthentication yes/c\PasswordAuthentication yes' /etc/ssh/sshd_config
sudo sed -i '/^PasswordAuthentication no/c\PasswordAuthentication yes' /etc/ssh/sshd_config

# Restart SSH service to apply changes
sudo systemctl restart ssh

# Add "lemongreen" to the sudo group
sudo usermod -aG sudo lemongreen

# Confirm completion
echo "User 'lemongreen' has been created, password login disabled locally, remote login restricted to specified host, and sudo requires a password."
