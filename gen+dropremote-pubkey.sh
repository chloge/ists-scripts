#!/bin/bash

# Prompt for the user's IP address
read -p "Enter the IP address to forward the public key: " ip_address
read -p "Enter the username on the remote host: " remote_user

# Check if the key pair already exists
if [ -f ~/.ssh/id_rsa ] && [ -f ~/.ssh/id_rsa.pub ]; then
  read -p "SSH key pair already exists. Do you want to overwrite it? (y/n): " overwrite_keys
  if [ "$overwrite_keys" = "y" ]; then
    ssh-keygen -t rsa -b 2048 -f ~/.ssh/id_rsa -N ""
  else
    echo "Using existing SSH key pair."
  fi
else
  ssh-keygen -t rsa -b 2048 -f ~/.ssh/id_rsa -N ""
fi

# Ensure the .ssh directory and authorized_keys file exist on the remote host
ssh $remote_user@$ip_address 'mkdir -p ~/.ssh && touch ~/.ssh/authorized_keys'

# Copy the public key to the remote host's authorized_keys file
ssh-copy-id -i ~/.ssh/id_rsa.pub $remote_user@$ip_address

# Print the location of the private key
echo "Private key generated and stored at: ~/.ssh/id_rsa"

# Verify the public key has been forwarded
echo "Public key forwarded to $remote_user@$ip_address. You can now use the public key for authentication."

# Prompt user to secure copy the private key
read -p "Would you like to secure copy the private key to the remote host's /tmp directory? (y/n): " scp_private_key

if [ "$scp_private_key" = "y" ]; then
    scp ~/.ssh/id_rsa $remote_user@$ip_address:/tmp/
    echo "Private key securely copied to /tmp on $remote_user@$ip_address."
else
    echo "Private key not copied."
fi
