#!/bin/bash

read -p "Enter the IP address to forward the public key: " ip_address
read -p "Enter the username on the remote host: " remote_user

ssh-keygen -t rsa -b 2048 -f ~/.ssh/id_rsa -N ""

# Ensure the .ssh directory and authorized_keys file exist on the remote host
ssh $remote_user@$ip_address 'mkdir -p ~/.ssh && touch ~/.ssh/authorized_keys'

ssh-copy-id -i ~/.ssh/id_rsa.pub $remote_user@$ip_address

echo "Private key generated at ~/.ssh/id_rsa"

echo "Public key forwarded to $remote_user@$ip_address. You can now use the public key for authentication."

# Prompt user to secure copy the private key
read -p "Would you like to secure copy the private key to the remote host's /tmp directory? (y/n): " scp_private_key

if [ "$scp_private_key" = "y" ]; then
    scp ~/.ssh/id_rsa $remote_user@$ip_address:/tmp/
    echo "Private key securely copied to /tmp on $remote_user@$ip_address."
else
    echo "Private key not copied."
fi

