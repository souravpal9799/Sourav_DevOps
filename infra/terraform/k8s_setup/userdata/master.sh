#!/bin/bash

set -e

echo "Disabling swap..."
sudo swapoff -a
sudo sed -i '/ swap / s/^/#/' /etc/fstab

echo "Enabling required kernel modules..."
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

echo "Setting sysctl params..."
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

sudo sysctl --system

echo "Installing containerd..."
sudo apt update -y
sudo apt install -y containerd

sudo mkdir -p /etc/containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml

sudo systemctl restart containerd
sudo systemctl enable containerd

echo "Installing Kubernetes components..."
sudo apt install -y apt-transport-https ca-certificates curl gpg

sudo curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt update -y
sudo apt install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

echo "Common setup complete!"


sudo hostnamectl set-hostname kube-master

echo "Fetching Private IP..."
PRIVATE_IP=$(hostname -I | awk '{print $1}')

echo "Master Private IP: $PRIVATE_IP"

echo "Initializing Kubernetes master..."

KUBEADM_OUTPUT="/tmp/kubeadm-init-output.txt"
sudo kubeadm init \
  --apiserver-advertise-address=$PRIVATE_IP \
  --pod-network-cidr=192.168.0.0/16 2>&1 | sudo tee "$KUBEADM_OUTPUT"

# Extract and save the join command for worker nodes
WORKER_JOIN_FILE="/home/ubuntu/worker-join.txt"
sudo awk '/kubeadm join/{found=1} found{print; if(/\\$/){next} else exit}' "$KUBEADM_OUTPUT" | \
  tr -d '\n' | sed 's/\\//g' | sed 's/  */ /g' | sed 's/^[[:space:]]*//' | sudo tee "$WORKER_JOIN_FILE" > /dev/null
sudo chown ubuntu:ubuntu "$WORKER_JOIN_FILE" 2>/dev/null || true

echo "Join command saved to $WORKER_JOIN_FILE"

echo "Setting up kubeconfig..."

# For root (userdata runs as root)
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# For ubuntu user (so kubectl works when you SSH in as ubuntu)
UBUNTU_HOME="/home/ubuntu"
if [ -d "$UBUNTU_HOME" ]; then
  sudo mkdir -p "$UBUNTU_HOME/.kube"
  sudo cp -i /etc/kubernetes/admin.conf "$UBUNTU_HOME/.kube/config"
  sudo chown -R ubuntu:ubuntu "$UBUNTU_HOME/.kube"
fi

echo "Installing Calico CNI..."
sudo kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.27.0/manifests/calico.yaml

echo ""
echo "Master setup complete!"
echo "To add workers: copy /home/ubuntu/worker-join.txt to each worker and run:"
echo "  sudo \$(cat /home/ubuntu/worker-join.txt)"
