#!/bin/bash

CLIENT_USER="rsyncuser"  # Change to your desired client-side rsync user
LOCAL_SYNC_FOLDER="/home/rage/QLServer/data/rsync_test"  # Local folder to sync with server
SSH_FOLDER="/home/${CLIENT_USER}/.ssh"
FOLDER_GROUP=$(stat -c "%G" "${LOCAL_SYNC_FOLDER}")
KEY_NAME="rsync_key"
RSYNC_REMOTE_SERVER="198.58.119.252"
RSYNC_REMOTE_FOLDER="/home/ql/T7Tx1/steamapps"
RSYNC_REMOTE_USER="rsyncuser"

# Check if user exists, if not, create the user with restricted shell
if ! id "${CLIENT_USER}" &>/dev/null; then
    sudo useradd -m -d "/home/${CLIENT_USER}" -s /bin/rbash "${CLIENT_USER}" || { echo "Failed to create user ${CLIENT_USER}"; exit 1; }
    echo "User ${CLIENT_USER} created with restricted shell access."
fi

usermod -a -G "${FOLDER_GROUP}" "${CLIENT_USER}"

# SSH config 
echo "Do you need to create the SSH directory and generate SSH key pair? (yes/no, default YES)"
read configure_ssh
configure_ssh=${configure_ssh:-yes}

if [ "$configure_ssh" = "yes" ]; then
    # Create the SSH directory and generate SSH key pair
    sudo -u "${CLIENT_USER}" mkdir -p "${SSH_FOLDER}"
    sudo -u "${CLIENT_USER}" ssh-keygen -t rsa -b 2048 -f "${SSH_FOLDER}/${KEY_NAME}" -N ""
    echo "SSH folder configured"
    
    # Output the public key
    echo "Please add the following public key to the server's /home/rsyncuser/.ssh/authorized_keys file:"
    sudo cat "${SSH_FOLDER}/${KEY_NAME}.pub" | sed "s/^/command=\"\\/home\\/syncuser\\/rrsync -ro \\/path\\/to\\/sync\\/folder\",no-agent-forwarding,no-X11-forwarding,no-port-forwarding /"
else
    # Ensure the SSH folder exists
    if [ ! -d "${SSH_FOLDER}" ]; then
        sudo -u "${CLIENT_USER}" mkdir -p "${SSH_FOLDER}"  
    else 
        echo "The SSH folder ${SSH_FOLDER} already exists."
    fi

    echo "Paste the SSH private key value below. Press Ctrl+D when finished:"
    IFS=  # Disable interpretation of backslash escapes
    sudo -u "${CLIENT_USER}" tee "${SSH_FOLDER}/${KEY_NAME}" >/dev/null
fi



# Set permissions for the SSH folder and key
sudo chmod 700 "${SSH_FOLDER}"
sudo chmod 600 "${SSH_FOLDER}/${KEY_NAME}"

# Create local sync folder if it doesn't exist
if [ ! -d "${LOCAL_SYNC_FOLDER}" ]; then
    sudo -u "${CLIENT_USER}" mkdir -p "${LOCAL_SYNC_FOLDER}"
    echo "Local sync folder created at ${LOCAL_SYNC_FOLDER}."
else
    echo "Local sync folder already exists at ${LOCAL_SYNC_FOLDER}."
fi

# Ensure the sync folder and its subfolders are accessible by the group
find ${LOCAL_SYNC_FOLDER} -type d -exec chmod g+rx {} +

# Ensure all files within the sync folder and subfolders are readable by the group
find ${LOCAL_SYNC_FOLDER} -type f -exec chmod g+r {} +

# Executing rsync
sudo -u "${CLIENT_USER}" rsync -avz -e "ssh -i ${SSH_FOLDER}/${KEY_NAME}" "${RSYNC_REMOTE_USER}@${RSYNC_REMOTE_SERVER}:${RSYNC_REMOTE_FOLDER}" "${LOCAL_SYNC_FOLDER}/"
