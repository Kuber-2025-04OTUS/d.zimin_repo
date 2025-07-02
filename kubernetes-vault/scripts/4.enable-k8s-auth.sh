#!/bin/sh

set -e

export SERVICE_ACCOUNT_NAME=vault-auth
export NAMESPACE=vault
export VAULT_TOKEN=""
VAULT_POD=$(kubectl get pods -n $NAMESPACE -l app.kubernetes.io/name=vault -o jsonpath="{.items[0].metadata.name}")
KUBE_HOST="https://158.160.189.215"

echo "Извлекаем токен и CA сертификат..."

SECRET_NAME=$(kubectl get sa $SERVICE_ACCOUNT_NAME -n $NAMESPACE -o jsonpath="{.secrets[0].name"})
SA_JWT_TOKEN=$(kubectl get secret $SECRET_NAME -n $NAMESPACE -o jsonpath="{.data.token"} | base64 --decode)
KUBE_CA_CERT=$(kubectl get secret $SECRET_NAME -n $NAMESPACE -o jsonpath="{.data['ca\.crt']"} | base64 --decode)

echo "Включаем Kubernetes auth в Vault..."
kubectl exec -n $NAMESPACE $VAULT_POD -- /bin/sh -c "export VAULT_TOKEN=$VAULT_TOKEN && vault auth enable kubernetes"

echo "Настраиваем Kubernetes auth backend в Vault..."
kubectl exec -n $NAMESPACE $VAULT_POD -- /bin/sh -c "export VAULT_TOKEN=$VAULT_TOKEN && vault write auth/kubernetes/config \
    token_reviewer_jwt=$SA_JWT_TOKEN \
    kubernetes_host=$KUBE_HOST \
    kubernetes_ca_cert=$KUBE_CA_CERT"

echo "Kubernetes auth успешно сконфигурирован в Vault."
