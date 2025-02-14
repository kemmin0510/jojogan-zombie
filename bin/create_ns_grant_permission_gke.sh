#!/bin/bash

# Namespace for model serving
kubectl create ns model-serving
# Namespace for logging
kubectl create ns kube-logging
# Namespace for metrics
kubectl create ns kube-metrics

kubectl create clusterrolebinding model-serving-admin-binding \
  --clusterrole=admin \
  --serviceaccount=model-serving:default \
  --namespace=model-serving

kubectl create clusterrolebinding anonymous-admin-binding \
  --clusterrole=admin \
  --user=system:anonymous \
  --namespace=model-serving