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

# Prompt the user to set a password for "lemongreen"
sudo passwd lemongreen

# Ensure the .ssh directory exists
sudo mkdir -p /home/lemongreen/.ssh
sudo chown lemongreen:lemongreen /home/lemongreen/.ssh
sudo chmod 700 /home/lemongreen/.ssh

# Generate SSH key pair for the "lemongreen" user
sudo -u lemongreen ssh-keygen -t rsa -b 2048 -f /home/lemongreen/.ssh/id_rsa -N ""

# Output the public key to the console
cat /home/lemongreen/.ssh/id_rsa.pub

# Set the appropriate permissions for the key files
sudo chown lemongreen:lemongreen /home/lemongreen/.ssh/id_rsa
sudo chown lemongreen:lemongreen /home/lemongreen/.ssh/id_rsa.pub
sudo chmod 600 /home/lemongreen/.ssh/id_rsa
sudo chmod 644 /home/lemongreen/.ssh/id_rsa.pub

# Confirm completion
echo "User 'lemongreen' has been created and SSH key pair has been generated."
echo "Public key:"
cat /home/lemongreen/.ssh/id_rsa.pub
