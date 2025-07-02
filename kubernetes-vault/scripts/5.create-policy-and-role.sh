#!/bin/sh

set -e

export VAULT_TOKEN=""
export NAMESPACE=vault
export SERVICE_ACCOUNT_NAME=vault-auth

kubectl cp otus-policy.hcl vault/vault-0:/tmp/otus-policy.hcl

kubectl exec -n vault vault-0 -- \
  /bin/sh -c "export VAULT_TOKEN=$VAULT_TOKEN && \
  vault policy write otus-policy /tmp/otus-policy.hcl"

kubectl exec -n vault vault-0 -- /bin/sh -c \
"export VAULT_TOKEN=$VAULT_TOKEN && \
vault write auth/kubernetes/role/otus \
  bound_service_account_names=$SERVICE_ACCOUNT_NAME \
  bound_service_account_namespaces=$NAMESPACE \
  policies=otus-policy \
  ttl=24h"
