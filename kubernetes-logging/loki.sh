#!/bin/sh

set -e

NAMESPACE="loki"

# Добавляем репозиторий Grafana
helm repo add grafana https://grafana.github.io/helm-charts 2>/dev/null || true
helm repo update

if [ "$1" = "i" ]; then
    # https://github.com/grafana/loki/blob/main/production/helm/loki/values.yaml
    helm upgrade --install loki grafana/loki \
      --namespace "$NAMESPACE" --create-namespace \
      --values "values-loki.yml"

    # https://github.com/grafana/helm-charts/blob/main/charts/grafana/values.yaml
    helm upgrade --install grafana grafana/grafana \
      --namespace "$NAMESPACE" \
      --values "values-grafana.yml"
    
    # https://github.com/grafana/helm-charts/blob/main/charts/promtail/values.yaml
    helm upgrade --install promtail grafana/promtail \
      --namespace "$NAMESPACE" \
      --values "values-promtail.yml"
elif [ "$1" = "u" ]; then
    helm uninstall grafana -n "$NAMESPACE"
    helm uninstall loki -n "$NAMESPACE"
    helm uninstall promtail -n "$NAMESPACE"
fi
