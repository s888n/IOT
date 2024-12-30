# -*- mode: ruby -*-
# vi: set ft=ruby :

server_ip =  "192.168.56.110"
agent_ip  =  "192.168.56.111"

server_scirpt = <<-SHELL
  sudo -i
  apk update
  apk add curl
  export INSTALL_K3S_EXEC="--bind-address=#{server_ip} --node-external-ip=#{server_ip} --flannel-iface=eth1"
  curl -sfL https://get.k3s.io | sh -
  echo "Sleeping for 5 seconds to wait for k3s to start"
  sleep 5
  cp /var/lib/rancher/k3s/server/token /vagrant_shared
  cp /etc/rancher/k3s/k3s.yaml /vagrant_shared
  SHELL

agent_script = <<-SHELL
  sudo -i
  apk update
  apk add curl
  export K3S_TOKEN_FILE=/vagrant_shared/token
  export K3S_URL=https://#{server_ip}:6443
  export INSTALL_K3S_EXEC="--flannel-iface=eth1"
  curl -sfL https://get.k3s.io | sh -
  SHELL

Vagrant.configure("2") do |config|
  config.vm.box = "generic/alpine318"

  config.vm.define "srachdiS" do |c|
    c.vm.hostname = "srachdiS"
    c.vm.network "private_network", ip: server_ip
    c.vm.synced_folder "./shared", "/vagrant_shared"
    c.vm.provider "virtualbox" do |v|
      v.customize ["modifyvm", :id, "--name", "srachdiS","--cpus", 2, "--memory", 1024]
    end
    c.vm.provision "shell", inline: server_scirpt
  end
  config.vm.define "srachdiSW" do |c|
    c.vm.hostname = "srachdiSW"
    c.vm.network "private_network", ip: agent_ip
    c.vm.synced_folder "./shared", "/vagrant_shared"
    c.vm.provider "virtualbox" do |v|
      v.customize ["modifyvm", :id, "--name", "srachdiSW","--cpus", 1, "--memory", 1024]
    end
    c.vm.provision "shell", inline: agent_script
  end
end
