#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/.env" ]; then
  export $(grep -v '^#' "$SCRIPT_DIR/.env" | xargs)
else
  echo "⚠️ File .env not found in $SCRIPT_DIR"
  exit 1
fi

# Add Elastic Helm repo
helm repo add elastic https://helm.elastic.co
helm repo update

# Create secrets for Elastic
kubectl create secret generic elastic-credentials -n kube-logging \
  --from-literal=username=$ELASTIC_USERNAME \
  --from-literal=password=$ELASTIC_PASSWORD \
  --from-literal=host=$ELASTIC_HOST \
  --from-literal=port=$ELASTIC_PORT \
  --dry-run=client -o yaml | kubectl apply -f -

# Debug mode. We do not have the certificates yet
kubectl create secret generic elasticsearch-master-certs -n kube-logging

helm upgrade --install filebeat elastic/filebeat -n kube-logging -f $SCRIPT_DIR/filebeat/values.yaml
