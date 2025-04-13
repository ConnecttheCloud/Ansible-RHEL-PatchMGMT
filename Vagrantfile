
# Vagrant.configure("2") do |config|
#   config.vm.define "ansible" do |ansible|
#     ansible.vm.box = "iamseth/rhel-7.3"
#     ansible.vm.box_version = "1.0.0"
#     ansible.vm.hostname = "ansible-redhat001"
#     ansible.vm.network "public_network", bridge: "Intel(R) Wi-Fi 6E AX211 160MHz", ip: "192.168.50.110"
#     # Configure provider
#     ansible.vm.provider "virtualbox" do |vb|
#       vb.gui = false
#       vb.memory = "2048"
#       vb.cpus = 2
#       vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
#       vb.customize ["modifyvm", :id, "--ioapic", "on"]
#     end
#     # Run a shell script
#     ansible.vm.provision "shell", inline: <<-SHELL
#     sudo ip route add default via 192.168.50.1
#     SHELL
#     ansible.vm.provision "shell", path: "./script.sh"
#   end

Vagrant.configure("2") do |config|
  config.vm.define "ansible" do |ansible|
    ansible.vm.box = "iamseth/rhel-7.3"
    ansible.vm.box_version = "1.0.0"
    ansible.vm.hostname = "ansible-redhat001"
    ansible.vm.network "public_network", bridge: "Intel(R) Wi-Fi 6E AX211 160MHz", ip: "192.168.50.110"

    ansible.vm.provider "virtualbox" do |vb|
      vb.gui = false
      vb.memory = "2048"
      vb.cpus = 2
      vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
      vb.customize ["modifyvm", :id, "--ioapic", "on"]
    end

    ansible.vm.provision "shell", inline: <<-SHELL
      sudo ip route add default via 192.168.50.1
    SHELL

    ansible.vm.provision "shell", env: {
      "RH_USERNAME" => ENV["RH_USERNAME"],
      "RH_PASSWORD" => ENV["RH_PASSWORD"]
    }, inline: <<-SHELL
      echo "Provisioning Debug: RH_USERNAME=$RH_USERNAME" >> /tmp/vagrant-provision.log
      echo "Provisioning Debug: RH_PASSWORD=$(if [ -n "$RH_PASSWORD" ]; then echo '[set, masked]'; else echo 'not set'; fi)" >> /tmp/vagrant-provision.log

      if [ -z "$RH_USERNAME" ] || [ -z "$RH_PASSWORD" ]; then
        echo "Error: RH_USERNAME and RH_PASSWORD must be set" >> /tmp/vagrant-provision.log
        exit 1
      fi

      sudo mkdir -p /etc/rhel-ansible
      sudo tee /etc/rhel-ansible/credentials.conf >/dev/null <<EOF
RH_USERNAME="$RH_USERNAME"
RH_PASSWORD="$RH_PASSWORD"
EOF
      sudo chmod 600 /etc/rhel-ansible/credentials.conf
    SHELL

    ansible.vm.provision "file", source: "./script.sh", destination: "/tmp/script.sh"
    ansible.vm.provision "shell", inline: <<-SHELL
      sudo mv /tmp/script.sh /usr/local/bin/rhel-subscribe-ansible.sh
      sudo chmod +x /usr/local/bin/rhel-subscribe-ansible.sh
      sudo /usr/local/bin/rhel-subscribe-ansible.sh
    SHELL
  end

    # Define the first client machine
  config.vm.define "client1" do |client1|
    client1.vm.box = "iamseth/rhel-7.3" #"geerlingguy/ubuntu2004"
    client1.vm.box_version = "1.0.0"
    client1.vm.hostname = "redhat-client1"
    client1.vm.network "public_network", bridge: "Intel(R) Wi-Fi 6E AX211 160MHz", ip: "192.168.50.111"
    client1.vm.provider "virtualbox" do |vb|
      vb.gui  = false
      vb.memory = "1024"
      vb.cpus = 2
      vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
      vb.customize ["modifyvm", :id, "--ioapic", "on"]
    end
    client1.vm.provision "shell", inline: <<-SHELL
    sudo ip route add default via 192.168.50.1
    cp /vagrant/sshkey/ansible_id_rsa.pub /home/vagrant/.ssh/authorized_keys &&  chmod 600 /home/vagrant/.ssh/authorized_keys
    echo Hello from Client1!
    SHELL
    client1.vm.provision "shell", env: {
      "RH_USERNAME" => ENV["RH_USERNAME"],
      "RH_PASSWORD" => ENV["RH_PASSWORD"]
    }, inline: <<-SHELL
      echo "Provisioning Debug: RH_USERNAME=$RH_USERNAME" >> /tmp/vagrant-provision.log
      echo "Provisioning Debug: RH_PASSWORD=$(if [ -n "$RH_PASSWORD" ]; then echo '[set, masked]'; else echo 'not set'; fi)" >> /tmp/vagrant-provision.log

      if [ -z "$RH_USERNAME" ] || [ -z "$RH_PASSWORD" ]; then
        echo "Error: RH_USERNAME and RH_PASSWORD must be set" | tee -a /tmp/vagrant-provision.log
        exit 1
      fi

      sudo mkdir -p /etc/rhel-ansible
      sudo tee /etc/rhel-ansible/credentials.conf >/dev/null <<EOF
RH_USERNAME="$RH_USERNAME"
RH_PASSWORD="$RH_PASSWORD"
EOF
      sudo chmod 600 /etc/rhel-ansible/credentials.conf
    SHELL

    client1.vm.provision "shell", inline: <<-SHELL
      source /etc/rhel-ansible/credentials.conf
      echo "Registering system with Red Hat..." 
      subscription-manager register --username="$RH_USERNAME" --password="$RH_PASSWORD"; sleep 3
      subscription-manager attach --auto
      subscription-manager repos --enable rhel-7-server-rpms && rm /etc/rhel-ansible/credentials.conf
    SHELL
  end


  #   # Define the Second client machine
  # config.vm.define "client2" do |client2|
  #   client2.vm.box = "ubuntu/jammy64" #"geerlingguy/ubuntu2004"
  #   client2.vm.box_version = "20241002.0.0"
  #   client2.vm.hostname = "client2"
  #   client2.vm.network "public_network", bridge: "Intel(R) Wi-Fi 6E AX211 160MHz", ip: "192.168.50.102"
  #   client2.vm.provider "virtualbox" do |vb|
  #     vb.gui  = false
  #     vb.memory = "512"
  #     vb.cpus = 2
  #     vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
  #     vb.customize ["modifyvm", :id, "--ioapic", "on"]
  #   end
  #   client2.vm.provision "shell", inline: <<-SHELL
  #   sudo ip route add default via 192.168.50.1
  #   cp /vagrant/sshkey/ansible_id_rsa.pub /home/vagrant/.ssh/authorized_keys &&  chmod 600 /home/vagrant/.ssh/authorized_keys
  #   echo Hello from Client2!
  #   SHELL
  
  # end

end

