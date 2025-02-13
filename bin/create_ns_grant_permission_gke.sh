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

kubectl create role jenkins-admin \
  --verb=get,list,watch,create,update,patch,delete \
  --resource=secrets,configmaps,services,deployments,daemonsets,statefulsets,pods \
  --namespace=model-serving

kubectl create role jenkins-admin \
  --verb=get,list,watch,create,update,patch,delete \
  --resource=secrets,configmaps,services,deployments,daemonsets,statefulsets,pods \
  --namespace=kube-metrics

kubectl create role jenkins-admin \
  --verb=get,list,watch,create,update,patch,delete \
  --resource=secrets,configmaps,services,deployments,daemonsets,statefulsets,pods \
  --namespace=kube-metrics

kubectl create rolebinding jenkins-admin-binding \
  --role=jenkins-admin \
  --serviceaccount=kube-metrics:default \
  --namespace=kube-metrics
