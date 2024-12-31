#!/bin/bash

# Variables
SYNC_FOLDER="/home/ql/rsync_test"  # Path of the folder to sync
USER="rsyncuser"                    # Dedicated user for rsync operations
FOLDER_GROUP=$(stat -c "%G" "${SYNC_FOLDER}")
# Function to download rrsync if not found
download_rrsync() {
    echo "rrsync script not found. Attempting to download..."
    curl -o /home/${USER}/rrsync https://raw.githubusercontent.com/WayneD/rsync/master/support/rrsync
}

# Ensure the rsync folder exists
if [ ! -d "${SYNC_FOLDER}" ]; then
    echo "The sync folder ${SYNC_FOLDER} does not exist."
    exit 1
fi

# Create the dedicated rsync user with restricted shell
# Check if the user already exists, and create if not
if id "${USER}" &>/dev/null; then
    echo "User ${USER} already exists, skipping creation."
else
    useradd -m -d /home/${USER} -s /bin/rbash ${USER} || { echo "Failed to create user ${USER}"; exit 1; }
fi


# Add rsync user to the owner's group to allow read access
usermod -a -G "${FOLDER_GROUP}" "${USER}"

echo "${USER} has been added to the ${FOLDER_GROUP} group."

# Ensure the sync folder and its subfolders are accessible by the group
find ${SYNC_FOLDER} -type d -exec chmod g+rx {} +

# Ensure all files within the sync folder and subfolders are readable by the group
find ${SYNC_FOLDER} -type f -exec chmod g+r {} +

# Set up the .ssh directory for the user
mkdir -p /home/${USER}/.ssh
touch /home/${USER}/.ssh/authorized_keys
chmod 700 /home/${USER}/.ssh
chmod 600 /home/${USER}/.ssh/authorized_keys
chown -R ${USER}:${USER} /home/${USER}/.ssh

# Try to locate and copy the rrsync script
if [ -f /usr/share/doc/rsync/scripts/rrsync.gz ]; then
    gzip -dc /usr/share/doc/rsync/scripts/rrsync.gz > /home/${USER}/rrsync
elif [ -f /usr/share/doc/rsync/scripts/rrsync ]; then
    cp /usr/share/doc/rsync/scripts/rrsync /home/${USER}/
else
    download_rrsync
fi

# Ensure rrsync is executable
chmod +x /home/${USER}/rrsync
chown ${USER}:${USER} /home/${USER}/rrsync

# Instruction for adding client public keys
echo "To enable a client to sync, add the client's SSH public key to /home/${USER}/.ssh/authorized_keys"
echo "Prefix each key with: command=\"/home/${USER}/rrsync -ro ${SYNC_FOLDER}\",no-agent-forwarding,no-X11-forwarding,no-port-forwarding"