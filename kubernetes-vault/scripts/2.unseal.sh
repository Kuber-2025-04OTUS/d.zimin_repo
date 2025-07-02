#!/bin/sh

set -e

export NAMESPACE=vault
VAULT_POD=$(kubectl get pods -n $NAMESPACE -l app.kubernetes.io/name=vault -o jsonpath="{.items[0].metadata.name}")

echo "Инициализируем Vault..."
INIT_OUTPUT=$(kubectl exec -n $NAMESPACE $VAULT_POD -- vault operator init -key-shares=3 -key-threshold=2)

# Парсим ключи
KEY1=$(echo "$INIT_OUTPUT" | grep 'Unseal Key 1:' | awk '{print $NF}')
KEY2=$(echo "$INIT_OUTPUT" | grep 'Unseal Key 2:' | awk '{print $NF}')
KEY3=$(echo "$INIT_OUTPUT" | grep 'Unseal Key 3:' | awk '{print $NF}')

# (опционально) сохраняем root token
ROOT_TOKEN=$(echo "$INIT_OUTPUT" | grep 'Initial Root Token:' | awk '{print $NF}')
echo "ROOT_TOKEN=$ROOT_TOKEN"

echo "Unsealing Vault pods..."

for i in 0 1 2; do
  echo "Unsealing vault-$i"
  kubectl exec -n $NAMESPACE vault-$i -- vault operator unseal "$KEY1"
  kubectl exec -n $NAMESPACE vault-$i -- vault operator unseal "$KEY2"
  kubectl exec -n $NAMESPACE vault-$i -- vault operator unseal "$KEY3"
done

echo "Готово. Vault разлочен."