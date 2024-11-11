#!/bin/bash

# Prompt for the user's IP address for public key forwarding
read -p "Enter the IP address to forward the public key: " public_ip_address
read -p "Enter the username on the remote host for public key forwarding: " public_remote_user

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

ssh $public_remote_user@$public_ip_address 'mkdir -p ~/.ssh && touch ~/.ssh/authorized_keys'

ssh-copy-id -i ~/.ssh/id_rsa.pub $public_remote_user@$public_ip_address

echo "Private key generated and stored at: ~/.ssh/id_rsa"
echo "Public key forwarded to $public_remote_user@$public_ip_address. You can now use the public key for authentication."

read -p "Would you like to secure copy the private key to a remote host's /tmp directory? (y/n): " scp_private_key

if [ "$scp_private_key" = "y" ]; then
    read -p "Enter the IP address to forward the private key: " private_ip_address
    read -p "Enter the username on the remote host for private key forwarding: " private_remote_user
    scp ~/.ssh/id_rsa $private_remote_user@$private_ip_address:/tmp/
    echo "Private key securely copied to /tmp on $private_remote_user@$private_ip_address."
else
    echo "Private key not copied."
fi
