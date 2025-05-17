#!/bin/sh

CLUSTER_NAME=$(kubectl config view --minify -o jsonpath='{.clusters[0].name}')
APISERVER=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}')
NAMESPACE="homework"
SA_NAME="cd"


kubectl -n $NAMESPACE apply -f - <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: ${SA_NAME}-token
  annotations:
    kubernetes.io/service-account.name: ${SA_NAME}
type: kubernetes.io/service-account-token
EOF

TOKEN=$(kubectl -n $NAMESPACE get secret ${SA_NAME}-token -o jsonpath='{.data.token}' | base64 --decode)

# Получаем CA сертификат
kubectl -n $NAMESPACE get secret ${SA_NAME}-token -o jsonpath='{.data.ca\.crt}' | base64 --decode > /tmp/ca.crt
CA_CERT=/tmp/ca.crt

kubectl config set-cluster ${CLUSTER_NAME} \
  --server=${APISERVER} \
  --certificate-authority=${CA_CERT} \
  --embed-certs=true \
  --kubeconfig=kubeconfig

kubectl config set-credentials ${SA_NAME} \
  --token=${TOKEN} \
  --kubeconfig=kubeconfig

kubectl config set-context ${SA_NAME}-context \
  --cluster=${CLUSTER_NAME} \
  --user=${SA_NAME} \
  --namespace=${NAMESPACE} \
  --kubeconfig=kubeconfig

kubectl config use-context ${SA_NAME}-context \
  --kubeconfig=kubeconfig