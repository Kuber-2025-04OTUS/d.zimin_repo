#!/bin/sh

set -e

if [ "$1" = "i" ]; then
    # K8S-CSI-S3
    # https://github.com/yandex-cloud/k8s-csi-s3
    helm repo add yandex-s3 https://yandex-cloud.github.io/k8s-csi-s3/charts   
    helm repo update
    helm install csi-s3 yandex-s3/csi-s3 -n homework

elif [ "$1" = "u" ]; then
    helm uninstall yandex-s3 -n homework
fi
