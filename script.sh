
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