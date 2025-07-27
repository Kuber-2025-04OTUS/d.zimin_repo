#!/bin/bash

K8S_VERSION="1.30"

K8S_VERSION_PATCH="1.30.0-1.1"

HOSTNAME="k8s-worker-1" # CHANGE FOE EACH NODE!

echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v'"${K8S_VERSION}"'/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt update

# Обновляем kubeadm
echo "ОБНОВЛЯЕМ KUBEADM ДО ВЕРСИИ"

sudo apt-mark unhold kubeadm && \
sudo apt-get update && sudo apt-get install -y kubeadm="'${K8S_VERSION_PATCH}'" && \
sudo apt-mark hold kubeadm

sudo kubeadm upgrade node

kubectl drain $HOSTNAME --ignore-daemonsets

echo "ОБНОВЛЯЕМ KUBELET И KUBECTL"
sudo apt-mark unhold kubelet kubectl && \
sudo apt-get update && sudo apt-get install -y kubelet kubectl && \
sudo apt-mark hold kubelet kubectl
sudo systemctl daemon-reload
sudo systemctl restart kubelet

kubectl uncordon $HOSTNAME