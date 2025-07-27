#!/bin/bash

K8S_VERSION="1.30"

echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v'"${K8S_VERSION}"'/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt update

echo ПОЛУЧИТЬ ВЕРСИЮ
sudo apt-cache madison kubeadm