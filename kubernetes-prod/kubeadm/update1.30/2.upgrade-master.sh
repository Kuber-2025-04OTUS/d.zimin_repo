#!/bin/bash

K8S_VERSION="1.30.0"

K8S_VERSION_PATCH="1.30.0-1.1"

HOSTNAME="k8s-master"

# Проверяем текущую версию
echo "ТЕКУЩАЯ ВЕРСИЯ КЛАСТЕРА:"
kubectl get nodes -o wide

# Обновляем kubeadm
echo "ОБНОВЛЯЕМ KUBEADM ДО ВЕРСИИ $K8S_VERSION"
sudo apt-mark unhold kubeadm && \
sudo apt-get update && sudo apt-get install -y kubeadm=$K8S_VERSION_PATCH && \
sudo apt-mark hold kubeadm

# Планируем обновление
echo "ПЛАНИРУЕМ ОБНОВЛЕНИЕ:"
sudo kubeadm upgrade plan

# Применяем обновление
echo "ПРИМЕНЯЕМ ОБНОВЛЕНИЕ ДО $K8S_VERSION"
sudo kubeadm upgrade apply v$K8S_VERSION -y

kubectl drain $HOSTNAME --ignore-daemonsets

# Обновляем kubelet и kubectl
echo "ОБНОВЛЯЕМ KUBELET И KUBECTL"
sudo apt-mark unhold kubelet kubectl && \
sudo apt-get update && sudo apt-get install -y kubelet kubectl && \
sudo apt-mark hold kubelet kubectl

sudo systemctl daemon-reload
sudo systemctl restart kubelet

kubectl uncordon $HOSTNAME

# Проверяем версию
echo "ОБНОВЛЕННАЯ ВЕРСИЯ MASTER-НОДЫ:"
kubectl version
kubectl get nodes -o wide