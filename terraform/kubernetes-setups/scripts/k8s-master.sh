#!/bin/bash
set -e

apt-get update
apt-get install -y docker.io apt-transport-https curl

systemctl enable docker
systemctl start docker

curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" \
  > /etc/apt/sources.list.d/kubernetes.list

apt-get update
apt-get install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl

kubeadm init --pod-network-cidr=10.244.0.0/16

mkdir -p /root/.kube
cp /etc/kubernetes/admin.conf /root/.kube/config
