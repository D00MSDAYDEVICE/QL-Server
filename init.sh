#!/bin/bash

common_hostnames=("localhost" "ubuntu" "debian" "centos" "fedora")
CLIENT_USER="rsyncuser"                                 #local rsync user
SSH_FOLDER="/home/${CLIENT_USER}/.ssh"                  # rsync local user ssh folder
KEY_NAME="rsync_key"                                    # rsync local user ssh key
RSYNC_REMOTE_SERVER="198.58.119.252"
RSYNC_REMOTE_PORT="2222"
RSYNC_REMOTE_FOLDER_1="/home/ql/T7Tx1/steamapps"        # sync workshop items (downloadable content)
RSYNC_REMOTE_FOLDER_2="/home/ql/T7Tx1/scripts"          # sync factories
RSYNC_REMOTE_FOLDER_3="/home/ql/T7Tx1/minqlx-plugins"   # sync minqlx plugins' scrips
RSYNC_REMOTE_USER="rsyncuser"
RSYNC_SSH_KEY="-----BEGIN OPENSSH PRIVATE KEY-----

-----END OPENSSH PRIVATE KEY-----"

current_hostname=$(hostname)

# Check if the current hostname is in the array of common hostnames
hostname_is_default=false
for hostname in "${common_hostnames[@]}"; do
    if [ "$current_hostname" == "$hostname" ]; then
        hostname_is_default=true
        break
    fi
done

# If the current hostname is a default one, ask if the user wants to update it
if [ "$hostname_is_default" = true ]; then
    echo "Your current hostname ('$current_hostname') is a common default hostname."
    echo "Do you want to update the hostname? (yes/no, default: yes)"
    read update_hostname
    update_hostname=${update_hostname:-yes}

    if [ "$update_hostname" == "yes" ]; then
        echo "Enter the new hostname:"
        read new_hostname
        hostnamectl set-hostname "$new_hostname"
        echo "Hostname updated to '$new_hostname'."
    else
        echo "Skipping hostname update."
    fi
else
    echo "Your current hostname ('$current_hostname') is not a common default hostname."
    echo "Skipping hostname update."
fi

# USER CREATION

echo "Do you need to create a new user? (yes/no, default NO)"
read create_user
create_user=${create_user:-no}

if [ "$create_user" = "yes" ]; then
    echo "Enter the username for the new user:"
    read username
    adduser $username
    usermod -aG sudo $username
    echo "New user $username created and added to the sudo group."
else
    echo "Please enter the username:"
    read username
fi
sudo -u "$username" mkdir -p /home/$username/QLServer/data
LOCAL_SYNC_FOLDER="/home/$username/QLServer/data/"
FOLDER_GROUP=$(stat -c "%G" "${LOCAL_SYNC_FOLDER}")
echo "Installing required packages..."

export DEBIAN_FRONTEND=noninteractive
apt update -qq
apt-get install -y -qq zsh curl unzip bat gh python3 python3-pip net-tools fonts-powerline -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"
sudo -u $username chsh -s $(which zsh)
sudo -u $username sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
sudo -u $username git clone --depth=1 https://github.com/romkatv/powerlevel10k.git /home/$username/.oh-my-zsh/custom/themes/powerlevel10k
sudo -u $username git clone https://github.com/zsh-users/zsh-autosuggestions.git /home/$username/.oh-my-zsh/custom/plugins/zsh-autosuggestions
sudo -u $username git clone https://github.com/zsh-users/zsh-syntax-highlighting.git /home/$username/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
cp -f .p10k.zsh /home/$username/
cp -f .zshrc /home/$username/
chmod 644 /home/$username/.p10k.zsh /home/$username/.zshrc

# DOCKER SETUP
if ! command -v docker &> /dev/null; then
    echo "Docker is not installed. Installing Docker..."
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt update
    sudo apt install -y docker-ce docker-ce-cli containerd.io
    sudo groupadd docker
    sudo usermod -aG docker $username
    echo "Docker installation complete. Please log out and back in for Docker group changes to take effect."
else
    echo "Docker is already installed."
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
    echo "Docker Compose is not installed. Installing Docker Compose..."
    sudo curl -L "https://github.com/docker/compose/releases/download/v2.24.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    echo "Docker Compose installation complete."
else
    echo "Docker Compose is already installed."
fi
unset DEBIAN_FRONTEND

# TIMEZONE SETUP

# Get the current system timezone
current_timezone=$(timedatectl | grep 'Time zone' | awk '{print $3}')

# Specify the default timezone you expect the system to be set to
default_timezone="America/New_York"

echo "The current system timezone is set to $current_timezone."

# Check if the current timezone matches the default timezone
if [ "$current_timezone" != "$default_timezone" ]; then
    echo "Do you want to configure the timezone? (yes/no, default YES)"
    read setup_timezone
    setup_timezone=${setup_timezone:-yes}

    if [ "$setup_timezone" = "yes" ]; then
        echo "Enter your desired timezone (e.g., Europe/London) or press Enter to use the default ($default_timezone):"
        read timezone
        timezone=${timezone:-$default_timezone}
        timedatectl set-timezone "$timezone"
        echo "Timezone is set to $(timedatectl | grep 'Time zone')"
    else
        echo "Skipping timezone configuration."
    fi
else
    echo "The system timezone is already set to $default_timezone. No changes made."
fi


# Configure the SSH folder
mkdir -p "${SSH_FOLDER}"
echo "${RSYNC_SSH_KEY}" > "${SSH_FOLDER}/${KEY_NAME}"
chmod 700 "${SSH_FOLDER}"
chmod 600 "${SSH_FOLDER}/${KEY_NAME}"

# Ensure rsync local user exists, otherwise create it with restricted shell
if ! id "${CLIENT_USER}" &>/dev/null; then
    useradd -m -d "/home/${CLIENT_USER}" -s /bin/rbash "${CLIENT_USER}" || { echo "Failed to create user ${CLIENT_USER}"; exit 1; }
    echo "User ${CLIENT_USER} created with restricted shell access."
fi

# Copy QLServer and set ownership for rsync to have access to the folder
cp -r ./ "/home/${username}/QLServer/"
chown -R "${CLIENT_USER}:${CLIENT_USER}" "/home/${username}/"

# Executing rsync
rsync -avz -e "ssh -p ${RSYNC_REMOTE_PORT} -o StrictHostKeyChecking=no -i ${SSH_FOLDER}/${KEY_NAME}" "${RSYNC_REMOTE_USER}@${RSYNC_REMOTE_SERVER}:${RSYNC_REMOTE_FOLDER_1}" "${LOCAL_SYNC_FOLDER}"
rsync -avz -e "ssh -p ${RSYNC_REMOTE_PORT} -o StrictHostKeyChecking=no -i ${SSH_FOLDER}/${KEY_NAME}" "${RSYNC_REMOTE_USER}@${RSYNC_REMOTE_SERVER}:${RSYNC_REMOTE_FOLDER_2}" "${LOCAL_SYNC_FOLDER}"
rsync -avz -e "ssh -p ${RSYNC_REMOTE_PORT} -o StrictHostKeyChecking=no -i ${SSH_FOLDER}/${KEY_NAME}" "${RSYNC_REMOTE_USER}@${RSYNC_REMOTE_SERVER}:${RSYNC_REMOTE_FOLDER_3}" "${LOCAL_SYNC_FOLDER}"

# Ensure created user owns the home directory and its contents after rsync finishes
chown -R "${username}:${username}" "/home/${username}/"

echo "Do you want to create a systemd service for the Quake Live Dedicated Server? (yes/no, default YES)"
read create_service
create_service=${create_service:-yes}

if [ "$create_service" = "yes" ]; then
    echo "Creating systemd service for Quake Live Dedicated Server..."
    SERVICE_FILE_CONTENT="[Unit]
Description=Quake Live Dedicated Server for $username
Requires=docker.service
After=docker.service

[Service]
Type=simple
User=$username
Group=$username
RemainAfterExit=yes
WorkingDirectory=/home/$username/QLServer
ExecStart=/usr/local/bin/docker-compose up -d
ExecStop=/usr/local/bin/docker-compose down
TimeoutStartSec=0

[Install]
WantedBy=multi-user.target"
    echo "$SERVICE_FILE_CONTENT" > /etc/systemd/system/docker-compose-qlds.service
    systemctl daemon-reload
    systemctl enable docker-compose-qlds.service
    systemctl enable --now docker-compose-qlds.service
    echo "Systemd service for Docker Compose has been created and started."
else
    echo "Skipping creation of systemd service."
fi


su $username