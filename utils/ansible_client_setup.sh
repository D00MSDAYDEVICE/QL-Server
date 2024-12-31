#!/bin/bash

set -e

# Define the Ansible user
ANSIBLE_USER=ansible

# Check if user exists, if not, create the user
if ! id "$ANSIBLE_USER" &>/dev/null; then
    echo "Creating user $ANSIBLE_USER..."
    sudo useradd -m -s /bin/bash $ANSIBLE_USER
    echo "User $ANSIBLE_USER created."
else
    echo "User $ANSIBLE_USER already exists."
fi

# Set up SSH directory and generate keys in PEM format
sudo -u $ANSIBLE_USER mkdir -p /home/$ANSIBLE_USER/.ssh
echo "Generating SSH keys in PEM format..."
sudo -u $ANSIBLE_USER ssh-keygen -t rsa -b 2048 -m PEM -f /home/$ANSIBLE_USER/.ssh/id_rsa -N "" -C "$ANSIBLE_USER@$(hostname)"
echo "SSH keys generated."

# Append the public key to authorized_keys and ensure it exists with correct permissions
if [ ! -f /home/$ANSIBLE_USER/.ssh/authorized_keys ]; then
    echo "Creating authorized_keys file..."
    sudo -u $ANSIBLE_USER touch /home/$ANSIBLE_USER/.ssh/authorized_keys
fi

echo "Appending public key to authorized_keys..."
sudo -u $ANSIBLE_USER cat /home/$ANSIBLE_USER/.ssh/id_rsa.pub >> /home/$ANSIBLE_USER/.ssh/authorized_keys

# Set proper permissions for SSH directory and its contents
echo "Setting permissions for SSH directory and files..."
sudo chmod 700 /home/$ANSIBLE_USER/.ssh
sudo chmod 600 /home/$ANSIBLE_USER/.ssh/id_rsa
sudo chmod 644 /home/$ANSIBLE_USER/.ssh/id_rsa.pub
sudo chmod 600 /home/$ANSIBLE_USER/.ssh/authorized_keys
sudo chown -R $ANSIBLE_USER:$ANSIBLE_USER /home/$ANSIBLE_USER/.ssh

# Configure passwordless sudo
echo "Configuring passwordless sudo..."
echo "$ANSIBLE_USER ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/$ANSIBLE_USER
sudo chmod 0440 /etc/sudoers.d/$ANSIBLE_USER

# Validate sudoers file to ensure no syntax errors
sudo visudo -c

# Output the public key
echo "SSH public key for $ANSIBLE_USER:"
sudo cat /home/$ANSIBLE_USER/.ssh/id_rsa.pub

echo "Setup complete."
echo "Private Key:"
sudo cat /home/$ANSIBLE_USER/.ssh/id_rsa