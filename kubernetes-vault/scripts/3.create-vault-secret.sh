#!/bin/sh

set -e

export VAULT_TOKEN=""
export NAMESPACE=vault
VAULT_POD=$(kubectl get pods -n $NAMESPACE -l app.kubernetes.io/name=vault -o jsonpath="{.items[0].metadata.name}")

kubectl exec -n $NAMESPACE $VAULT_POD -- /bin/sh -c "export VAULT_TOKEN=$VAULT_TOKEN && vault secrets enable -path=otus kv-v2"
kubectl exec -n $NAMESPACE $VAULT_POD -- /bin/sh -c "export VAULT_TOKEN=$VAULT_TOKEN && vault kv put otus/cred username=\"otus\" password=\"asajkjkahs\""
kubectl exec -n $NAMESPACE $VAULT_POD -- /bin/sh -c "export VAULT_TOKEN=$VAULT_TOKEN && vault kv get otus/cred"
