#!/bin/bash

kubeadm init

echo НАСТРАИВАЕМ KUBECTL ДЛЯ ОБЫЧНОГО ПОЛЬЗОВАТЕЛЯ
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

kubectl patch node k8s-master -p '{"spec":{"podCIDR":"10.244.0.0/24"}}'
kubectl patch node k8s-worker-1 -p '{"spec":{"podCIDR":"10.244.1.0/24"}}' # For k8s-worker-1
kubectl patch node k8s-worker-2 -p '{"spec":{"podCIDR":"10.244.2.0/24"}}' # For k8s-worker-2
kubectl patch node k8s-worker-3 -p '{"spec":{"podCIDR":"10.244.3.0/24"}}' # For k8s-worker-3

echo FLANNEL
kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml