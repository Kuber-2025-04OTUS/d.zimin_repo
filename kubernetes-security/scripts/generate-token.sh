#!/bin/sh

NAMESPACE="homework"
SA_NAME="cd"

kubectl -n $NAMESPACE create token $SA_NAME --duration=24h > token