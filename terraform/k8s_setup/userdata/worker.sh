#!/bin/bash

set -e

echo "🔹 Disabling swap..."
swapoff -a
sed -i '/ swap / s/^/#/' /etc/fstab

echo "🔹 Enabling required kernel modules..."
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

modprobe overlay
modprobe br_netfilter

echo "🔹 Setting sysctl params..."
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

sysctl --system

echo "🔹 Installing containerd..."
sudo apt update -y
sudo apt install -y containerd

sudo mkdir -p /etc/containerd
sudo containerd config default | tee /etc/containerd/config.toml
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml

systemctl restart containerd
systemctl enable containerd

echo "🔹 Installing Kubernetes components..."
apt install -y apt-transport-https ca-certificates curl gpg

curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /' | tee /etc/apt/sources.list.d/kubernetes.list

apt update -y
apt install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl

echo "✅ Common setup complete!"

######################################################################

echo "🚀 Fetching Public IP..."
PUBLIC_IP=$(curl -s https://ipinfo.io/ip)

echo "Master Public IP: $PUBLIC_IP"

echo "🚀 Initializing Kubernetes master..."

kubeadm init \
  --apiserver-advertise-address=$PUBLIC_IP \
  --pod-network-cidr=192.168.0.0/16

echo "🔹 Setting up kubeconfig..."

mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config

echo "🔹 Installing Calico CNI..."
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.27.0/manifests/calico.yaml

echo ""
echo "🎉 Master setup complete!"
echo "Run the kubeadm join command displayed above on worker nodes."
