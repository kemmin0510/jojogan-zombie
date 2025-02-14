#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/.env" ]; then
  export $(grep -v '^#' "$SCRIPT_DIR/.env" | xargs)
else
  echo "⚠️ File .env not found in $SCRIPT_DIR"
  exit 1
fi

# Install node-exporter
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm upgrade --install node-exporter prometheus-community/prometheus-node-exporter \
  --namespace kube-metrics \
  -f $SCRIPT_DIR/node_exporter/node-exporter-values.yaml
