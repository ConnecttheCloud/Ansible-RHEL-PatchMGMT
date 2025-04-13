# # #! /bin/bash
# # # Install prerequisites and add Ansible PPA
# # sudo apt install software-properties-common -y
# # sudo add-apt-repository --yes --update ppa:ansible/ansible

# # # Install Ansible (no extra update steps)
# # sudo apt install ansible -y


# #!/bin/bash

# # Install ansible

# set -e

# # Log file for debugging
# LOGFILE="/var/log/rhel-subscribe-ansible.log"
# exec > >(tee -a "$LOGFILE") 2>&1
# echo "Starting RHEL subscription and Ansible installation: $(date)"

# # Check if Ansible is already installed
# if rpm -q ansible > /dev/null 2>&1; then
#     echo "Ansible is already installed. Exiting."
#     ansible --version
#     exit 0
# fi

# # Check for root privileges
# if [ "$(id -u)" != "0" ]; then
#     echo "This script must be run as root."
#     exit 1
# fi

# # Fetch credentials from environment variables [powershell]
# RH_USERNAME="${RH_USERNAME:-}"
# RH_PASSWORD="${RH_PASSWORD:-}"

# # Option 2: Use a separate config file for credentials (recommended)
# # CREDENTIALS_FILE="/etc/rhel-subscribe-credentials.conf"
# # if [ -f "$CREDENTIALS_FILE" ]; then
# #     source "$CREDENTIALS_FILE"
# # else
# #     echo "Credentials file $CREDENTIALS_FILE not found."
# #     exit 1
# # fi


# # Validate environment variables
# if [ -z "$RH_USERNAME" ] || [ -z "$RH_PASSWORD" ]; then
#     echo "Error: RH_USERNAME and RH_PASSWORD environment variables must be set."
#     exit 1
# fi


# # Check internet connectivity
# echo "Checking internet connectivity..."
# ping -c 1 google.com > /dev/null 2>&1 || {
#     echo "No internet connection. Retrying in 5 seconds..."
#     sleep 5
#     ping -c 1 google.com > /dev/null 2>&1 || {
#         echo "Internet connection failed. Exiting."
#         exit 1
#     }
# }

# # Register and attach subscription
# echo "Registering system with Red Hat..."
# subscription-manager register --username="$RH_USERNAME" --password="$RH_PASSWORD" --auto-attach || {
#     echo "Failed to register or attach subscription. Check credentials or subscription status."
#     exit 1
# }

# # Enable the Ansible repository
# echo "Enabling rhel-7-server-ansible-2.9-rpms repository..."
# subscription-manager repos --enable rhel-7-server-ansible-2.9-rpms || {
#     echo "Failed to enable Ansible repository. Check subscription entitlements."
#     exit 1
# }

# # Clean yum cache
# echo "Cleaning yum cache..."
# yum clean all
# rm -rf /var/cache/yum

# # Install Ansible
# echo "Installing Ansible..."
# yum install -y ansible || {
#     echo "Failed to install Ansible. Check repository or network."
#     exit 1
# }

# # Verify Ansible installation
# echo "Verifying Ansible installation..."
# if rpm -q ansible > /dev/null 2>&1; then
#     echo "Ansible installed successfully."
#     ansible --version
# else
#     echo "Ansible verification failed."
#     exit 1
# fi

# # Mark the script as completed
# touch /etc/rhel-ansible-installed
# echo "Ansible installed successfully and system subscribed: $(date)"
# echo "Ansible version:"
# ansible --version


# PUBLIC_KEY=$(cat /vagrant/sshkey/ansible_id_rsa.pub | tr -d '\n')
# echo $PUBLIC_KEY >> /home/vagrant/.ssh/authorized_keys
# cp /vagrant/sshkey/ansible_id_rsa /home/vagrant/.ssh/
# sudo chown vagrant:vagrant /home/vagrant/.ssh/*
# chmod 600 /home/vagrant/.ssh/authorized_keys /home/vagrant/.ssh/ansible_id_rsa

# exit 0


# #!/bin/bash
# set -e
# LOGFILE="/var/log/rhel-subscribe-ansible.log"
# echo "Starting RHEL subscription and Ansible installation: $(date)" >> "$LOGFILE"
# if rpm -q ansible > /dev/null 2>&1; then
#     echo "Ansible is already installed. Exiting." >> "$LOGFILE"
#     ansible --version >> "$LOGFILE" 2>&1
#     exit 0
# fi
# if [ "$(id -u)" != "0" ]; then
#     echo "This script must be run as root." >> "$LOGFILE"
#     exit 1
# fi
# # Load credentials
# if [ -f /etc/rhel-ansible/credentials.conf ]; then
#     source /etc/rhel-ansible/credentials.conf
# else
#     echo "Debug: Credentials file not found, using environment variables" >> "$LOGFILE"
#     RH_USERNAME="${RH_USERNAME:-}"
#     RH_PASSWORD="${RH_PASSWORD:-}"
# fi
# echo "Debug: RH_USERNAME is set to: ${RH_USERNAME:-'not set'}" >> "$LOGFILE"
# echo "Debug: RH_PASSWORD is set to: $(if [ -n "${RH_PASSWORD:-}" ]; then echo '[set, masked]'; else echo 'not set'; fi)" >> "$LOGFILE"
# if [ -z "$RH_USERNAME" ] || [ -z "$RH_PASSWORD" ]; then
#     echo "Error: RH_USERNAME and RH_PASSWORD must be set." >> "$LOGFILE"
#     exit 1
# fi
# echo "Checking internet connectivity..." >> "$LOGFILE"
# ping -c 1 google.com > /dev/null 2>&1 || {
#     echo "No internet connection. Retrying in 10 seconds..." >> "$LOGFILE"
#     sleep 10
#     ping -c 1 google.com > /dev/null 2>&1 || {
#         echo "Internet connection failed. Exiting." >> "$LOGFILE"
#         exit 1
#     }
# }

# echo "Registering system with Red Hat..." >> "$LOGFILE"
#  subscription-manager register --username="$RH_USERNAME" --password="$RH_PASSWORD" --auto-attach >> "$LOGFILE" 2>&1 
#  #|| {
# #     echo "Failed to register or attach subscription. Check credentials or subscription status." >> "$LOGFILE"
# #     subscription-manager status >> "$LOGFILE" 2>&1 || echo "Unable to retrieve subscription status" >> "$LOGFILE"
# #     exit 1
# # }
# echo "Enabling rhel-7-server-ansible-2.9-rpms repository..." >> "$LOGFILE"
# subscription-manager repos --enable rhel-7-server-ansible-2.9-rpms >> "$LOGFILE" 2>&1 

# # || {
# #     echo "Failed to enable Ansible repository. Check subscription entitlements." >> "$LOGFILE"
# #     subscription-manager repos --list >> "$LOGFILE" 2>&1 || echo "Unable to list repositories" >> "$LOGFILE"
# #     exit 1
# # }

# echo "Cleaning yum cache..." >> "$LOGFILE"
# yum clean all >> "$LOGFILE" 2>&1
# rm -rf /var/cache/yum
# echo "Installing Ansible..." >> "$LOGFILE"
# yum install -y ansible >> "$LOGFILE" 2>&1 || {
#     echo "Failed to install Ansible. Check repository or network." >> "$LOGFILE"
#     yum repolist enabled >> "$LOGFILE" 2>&1 || echo "Unable to list enabled repositories" >> "$LOGFILE"
#     exit 1
# }

# echo "Verifying Ansible installation..." >> "$LOGFILE"
# if rpm -q ansible > /dev/null 2>&1; then
#     echo "Ansible installed successfully." >> "$LOGFILE"
#     ansible --version >> "$LOGFILE" 2>&1
# else
#     echo "Ansible verification failed." >> "$LOGFILE"
#     exit 1
# fi

# touch /etc/rhel-ansible-installed
# echo "Marker file created at /etc/rhel-ansible-installed: $(date)" >> "$LOGFILE"


#!/bin/bash
LOGFILE="/var/log/rhel-subscribe-ansible.log"
echo "Starting RHEL subscription and Ansible installation: $(date)" >> "$LOGFILE"

# Check if Ansible is already installed
if command -v ansible >/dev/null 2>&1; then
    echo "Ansible is already installed. Exiting." >> "$LOGFILE"
    ansible --version >> "$LOGFILE" 2>&1
    exit 0
fi

# Ensure root privileges
if [ "$(id -u)" != "0" ]; then
    echo "This script must be run as root." >> "$LOGFILE"
    exit 1
fi

# Load credentials
if [ -f /etc/rhel-ansible/credentials.conf ]; then
    source /etc/rhel-ansible/credentials.conf
else
    echo "Error: Credentials file /etc/rhel-ansible/credentials.conf not found." >> "$LOGFILE"
    exit 1
fi

echo "Debug: RH_USERNAME is set to: ${RH_USERNAME:-'not set'}" >> "$LOGFILE"
echo "Debug: RH_PASSWORD is set to: $(if [ -n "${RH_PASSWORD:-}" ]; then echo '[set, masked]'; else echo 'not set'; fi)" >> "$LOGFILE"
if [ -z "$RH_USERNAME" ] || [ -z "$RH_PASSWORD" ]; then
    echo "Error: RH_USERNAME and RH_PASSWORD must be set." >> "$LOGFILE"
    exit 1
fi

# Check internet connectivity
echo "Checking internet connectivity..." >> "$LOGFILE"
ping -c 1 google.com >/dev/null 2>&1 || {
    echo "No internet connection. Retrying in 10 seconds..." >> "$LOGFILE"
    sleep 10
    ping -c 1 google.com >/dev/null 2>&1 || {
        echo "Internet connection failed. Exiting." >> "$LOGFILE"
        exit 1
    }
}

# Clean up prior registration
echo "Cleaning up prior registration..." >> "$LOGFILE"
subscription-manager unregister >>"$LOGFILE" 2>&1 || true
subscription-manager clean >>"$LOGFILE" 2>&1

# Register system
echo "Registering system with Red Hat..." >> "$LOGFILE"
subscription-manager register --username="$RH_USERNAME" --password="$RH_PASSWORD" >> "$LOGFILE" 2>&1 || {
    echo "Registration failed. Check credentials." >> "$LOGFILE"
    subscription-manager list --available >>"$LOGFILE" 2>&1
    exit 1
}

# Attempt subscription attachment (non-critical)
echo "Attempting to attach subscription..." >> "$LOGFILE"
subscription-manager attach --auto >>"$LOGFILE" 2>&1 || {
    echo "Auto-attach failed. Continuing without attachment..." >> "$LOGFILE"
    subscription-manager list --available >>"$LOGFILE" 2>&1
}

# # Enable repositories
# echo "Enabling rhel-7-server-rpms repository..." >> "$LOGFILE"
# subscription-manager repos --enable rhel-7-server-rpms >>"$LOGFILE" 2>&1 || {
#     echo "Warning: Failed to enable rhel-7-server-rpms repository." >> "$LOGFILE"
# }

echo "Enabling rhel-7-server-ansible-2.9-rpms repository..." >> "$LOGFILE"
if subscription-manager repos --enable rhel-7-server-ansible-2.9-rpms >>"$LOGFILE" 2>&1; then
    echo "Ansible repository enabled successfully." >> "$LOGFILE"
    ANSIBLE_VIA_YUM=1
else
    echo "Warning: Failed to enable rhel-7-server-ansible-2.9-rpms. Falling back to pip." >> "$LOGFILE"
    ANSIBLE_VIA_YUM=0
fi

# Clean yum cache
echo "Cleaning yum cache..." >> "$LOGFILE"
yum clean all >>"$LOGFILE" 2>&1
rm -rf /var/cache/yum

# Install Ansible
echo "Installing Ansible..." >> "$LOGFILE"
if [ "$ANSIBLE_VIA_YUM" = "1" ]; then
    if yum install -y ansible >>"$LOGFILE" 2>&1; then
        echo "Ansible installed successfully via yum." | tee -a "$LOGFILE"
    else
        echo "Failed to install Ansible via yum. Trying pip..." >> "$LOGFILE"
        yum install -y python-pip >>"$LOGFILE" 2>&1 && pip install ansible >>"$LOGFILE" 2>&1 || {
            echo "Failed to install Ansible via pip." >> "$LOGFILE"
            exit 1
        }
        echo "Ansible installed successfully via pip." >> "$LOGFILE"
    fi
else
    yum install -y python-pip >>"$LOGFILE" 2>&1 && pip install ansible >>"$LOGFILE" 2>&1 || {
        echo "Failed to install Ansible via pip." >> "$LOGFILE"
        exit 1
    }
    echo "Ansible installed successfully via pip." >> "$LOGFILE"
fi

# Verify Ansible
echo "Verifying Ansible installation..." >> "$LOGFILE"
if command -v ansible >/dev/null 2>&1; then
    echo "Ansible verified successfully." | tee -a "$LOGFILE"
    ansible --version >>"$LOGFILE" 2>&1
else
    echo "Error: Ansible not installed." >> "$LOGFILE"
    exit 1
fi

echo "Setup completed successfully: $(date)" | tee -a "$LOGFILE"


PUBLIC_KEY=$(cat /vagrant/sshkey/ansible_id_rsa.pub | tr -d '\n')
echo $PUBLIC_KEY >> /home/vagrant/.ssh/authorized_keys
cp /vagrant/sshkey/ansible_id_rsa /home/vagrant/.ssh/
sudo chown vagrant:vagrant /home/vagrant/.ssh/*
chmod 600 /home/vagrant/.ssh/authorized_keys /home/vagrant/.ssh/ansible_id_rsa

# Remove debugging logs
if rm -rf /tmp/vagrant-provision.log && sudo rm /etc/rhel-ansible/credentials.conf; then
    echo "Debugging logs removed successfully." | tee -a "$LOGFILE"
else
    echo "Failed to remove debugging logs." | tee -a "$LOGFILE"
fi
exit 0