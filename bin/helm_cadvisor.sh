#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/.env" ]; then
  export $(grep -v '^#' "$SCRIPT_DIR/.env" | xargs)
else
  echo "⚠️ File .env not found in $SCRIPT_DIR"
  exit 1
fi

# Install cadvisor
helm repo add kiwigrid https://kiwigrid.github.io
helm repo update
helm install cadvisor kiwigrid/cadvisor

# Check pods available
kubectl get pods -l app.kubernetes.io/name=cadvisor

# Apply service
kubectl apply -f $SCRIPT_DIR/cadvisor/cadvisor-service.yaml