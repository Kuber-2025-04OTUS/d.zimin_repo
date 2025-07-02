#!/bin/sh

set -e

if [ "$1" = "i" ]; then
    # CONSUL
    # https://github.com/hashicorp/consul-k8s/blob/main/charts/consul/values.yaml
    helm repo add hashicorp https://helm.releases.hashicorp.com 2>/dev/null || true    
    helm repo update
    # Проверяем доступность чарта
    if ! helm search repo hashicorp/consul --versions | grep -q "consul"; then
        echo "Error: Consul chart not found in hashicorp repository"
        exit 1
    fi
    helm upgrade --install consul hashicorp/consul \
      --namespace consul \
      --create-namespace \
      --values "./helm/values-consul.yml"

    # # VAULT
    # # https://github.com/hashicorp/vault-helm/blob/main/values.yaml
    helm repo update
    helm upgrade --install vault hashicorp/vault \
      --namespace vault \
      --create-namespace \
      --values "./helm/values-vault.yml"

    # ESO
    helm repo add external-secrets https://charts.external-secrets.io
    helm repo update
    helm upgrade --install external-secrets external-secrets/external-secrets \
      --namespace vault

elif [ "$1" = "u" ]; then
    helm uninstall consul -n consul
    helm uninstall vault -n vault
    helm uninstall external-secrets -n vault
fi
