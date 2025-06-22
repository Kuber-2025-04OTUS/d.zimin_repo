#!/bin/sh

set -e

if [ "$1" = "i" ]; then
    # https://github.com/argoproj/argo-helm/blob/main/charts/argo-cd/values.yaml
    helm repo add argo https://argoproj.github.io/argo-helm 2>/dev/null || true
    helm repo update
    helm upgrade --install argocd argo/argo-cd \
      --namespace argo-cd --create-namespace \
      --values "values.yml"

    # https://github.com/kubernetes/ingress-nginx
    helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
    helm repo update
    helm upgrade --install nginx-ingress ingress-nginx/ingress-nginx --version 4.11.5 \
      --namespace ingress-nginx \
      --create-namespace
elif [ "$1" = "u" ]; then
    helm uninstall argocd -n argo-cd
    helm uninstall nginx-ingress -n ingress-nginx
fi
