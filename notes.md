```rb
# K3s Cluster Configuration
SERVER_IP = "192.168.56.110"
AGENT_IP = "192.168.56.111"
BOX_IMAGE = "debian/bookworm64"
SHARED_FOLDER = "./shared"
SHARED_VM_PATH = "/vagrant_shared"

# Ensure shared directory exists
Dir.mkdir(SHARED_FOLDER) unless Dir.exist?(SHARED_FOLDER)

# Installation scripts
SERVER_SCRIPT = <<-SHELL
  apt-get update && apt-get upgrade -y && apt-get install -y curl
  export INSTALL_K3S_EXEC="--bind-address=#{SERVER_IP} --node-external-ip=#{SERVER_IP} --flannel-iface=eth1"
  curl -sfL https://get.k3s.io | sh - || { echo "Failed to install k3s"; exit 1; }
  echo "Waiting for k3s to initialize..."
  sleep 5
  cp /var/lib/rancher/k3s/server/token #{SHARED_VM_PATH}/token || { echo "Failed to copy token"; exit 1; }
  cp /etc/rancher/k3s/k3s.yaml #{SHARED_VM_PATH}/k3s.yaml || { echo "Failed to copy k3s.yaml"; exit 1; }
  # Replace localhost with server IP in kubeconfig for external access
  sed -i 's/127.0.0.1/#{SERVER_IP}/g' #{SHARED_VM_PATH}/k3s.yaml
  echo "K3s server setup complete"
SHELL

AGENT_SCRIPT = <<-SHELL
  apt-get update && apt-get upgrade -y && apt-get install -y curl
  export K3S_TOKEN_FILE=#{SHARED_VM_PATH}/token
  export K3S_URL=https://#{SERVER_IP}:6443
  export INSTALL_K3S_EXEC="--flannel-iface=eth1"
  curl -sfL https://get.k3s.io | sh - || { echo "Failed to install k3s agent"; exit 1; }
  echo "K3s agent setup complete"
SHELL

Vagrant.configure("2") do |config|
  # Common configuration
  config.vm.box = BOX_IMAGE
  
  # Enable port forwarding from vagrant ssh command
  config.ssh.forward_agent = true
  
  # Server node
  config.vm.define "server", primary: true do |server|
    server.vm.hostname = "srachdiS"
    server.vm.network "private_network", ip: SERVER_IP
    server.vm.synced_folder SHARED_FOLDER, SHARED_VM_PATH, create: true
    
    server.vm.provider "virtualbox" do |vb|
      vb.name = "srachdiS"
      vb.cpus = 2
      vb.memory = 2048 # Increased for better server performance
      vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    end
    
    server.vm.provision "shell", inline: SERVER_SCRIPT
  end
  
  # Agent node
  config.vm.define "agent", depends_on: ["server"] do |agent|
    agent.vm.hostname = "srachdiSW"
    agent.vm.network "private_network", ip: AGENT_IP
    agent.vm.synced_folder SHARED_FOLDER, SHARED_VM_PATH, create: true
    
    agent.vm.provider "virtualbox" do |vb|
      vb.name = "srachdiSW"
      vb.cpus = 1
      vb.memory = 1024
      vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    end
    
    agent.vm.provision "shell", inline: AGENT_SCRIPT
  end
end
```