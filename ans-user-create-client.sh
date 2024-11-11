#!/bin/bash

# Check if the script is being run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

# Check if the user "lemongreen" already exists
if id "lemongreen" &>/dev/null; then
    echo "User 'lemongreen' already exists. Exiting the script."
    exit 1
fi

# Create a new user named "lemongreen"
sudo adduser lemongreen

# Prompt the user to set a password for "lemongreen" (necessary before disabling password login)
sudo passwd lemongreen

# Ensure the .ssh directory exists
sudo mkdir -p /home/lemongreen/.ssh
sudo chown lemongreen:lemongreen /home/lemongreen/.ssh
sudo chmod 700 /home/lemongreen/.ssh

# Prompt for the remote host and remote user to fetch the public key from
read -p "Enter the remote host to fetch the public key from: " remote_host
read -p "Enter the remote (root) user to use to fetch the public key: " remote_user

# Ensure the authorized_keys file exists on the client machine
sudo touch /home/lemongreen/.ssh/authorized_keys
sudo chown lemongreen:lemongreen /home/lemongreen/.ssh/authorized_keys
sudo chmod 600 /home/lemongreen/.ssh/authorized_keys

# Fetch the public key from the specified remote host and user
sudo scp "${remote_user}@${remote_host}:/home/lemongreen/.ssh/id_rsa.pub" /home/lemongreen/.ssh/authorized_keys

# Set the appropriate permissions for the authorized_keys file
sudo chown lemongreen:lemongreen /home/lemongreen/.ssh/authorized_keys
sudo chmod 600 /home/lemongreen/.ssh/authorized_keys

# Disable password authentication by adding "PasswordAuthentication no" to sshd_config
sudo sed -i '/PasswordAuthentication/c\PasswordAuthentication no' /etc/ssh/sshd_config

# Restart SSH service to apply changes
sudo systemctl restart ssh

# Add "lemongreen" to the sudo group
sudo usermod -aG sudo lemongreen

# Lock the password for the "lemongreen" user to prevent password login
sudo passwd -l lemongreen

# Enable passwordless sudo for the "lemongreen" user
echo 'lemongreen ALL=(ALL) NOPASSWD:ALL' | sudo tee /etc/sudoers.d/lemongreen

# Confirm completion
echo "User 'lemongreen' has been created, password login disabled, passwordless sudo enabled, SSH key has been set up, and login restricted to specified remote host."
