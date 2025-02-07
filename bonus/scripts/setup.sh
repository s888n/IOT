#!/bin/bash

set -e

# Update package list and install dependencies silently
echo "Installing dependencies..."
apt-get update -q > /dev/null
apt-get install -y -q curl vim > /dev/null
# Install Docker
echo "Installing Docker..."
curl -fsSL https://get.docker.com -o get-docker.sh > /dev/null
sh get-docker.sh > /dev/null


# Install k3d
echo "Installing k3d..."
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash > /dev/null

# Create a k3d cluster
echo "Creating  'dev-cluster'..."
k3d cluster create dev-cluster --api-port 6550 --port 8081:80@loadbalancer --port 8082:443@loadbalancer > /dev/null

# Install kubectl
echo "Installing kubectl..."
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" > /dev/null
install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl > /dev/null

# install helm
echo "Installing Helm..."
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh > /dev/null


export KUBECONFIG="$(k3d kubeconfig write dev-cluster)" > /dev/null
# Check k3d cluster
echo "Checking k3d cluster..."
kubectl cluster-info
kubectl get nodes