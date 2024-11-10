#!/bin/bash

KIND_EXPERIMENTAL_PROVIDER=podman  systemd-run --scope --user -p "Delegate=yes" kind create cluster

kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.16.1/cert-manager.yaml

podman build -t docker.io/library/scp:latest -f scp.dockerfile
podman build -t docker.io/library/fcm:latest -f fcm.dockerfile
podman pull valkey/valkey:latest

kind load docker-image fcm
kind load docker-image scp
kind load docker-image valkey/valkey

openssl req -x509 -nodes -days 365 -newkey rsa:4096 -keyout ca.key -out ca.crt -subj "/CN=wintrading"
openssl req -x509 -nodes -days 365 -newkey rsa:4096 -keyout scp.key -out scp.crt -subj "/CN=scp-service"

kubectl create configmap ca-crt --from-file=ca.crt=ca.crt
kubectl create configmap fcm-cred --from-file=credentials.json=credentials.json
kubectl create secret generic ca-secret --namespace cert-manager --from-file=tls.crt=ca.crt --from-file=tls.key=ca.key
kubectl create secret generic scp-secret --from-file=tls.crt=scp.crt --from-file=tls.key=scp.key

kubectl apply -f cert-manager.yaml
kubectl apply -f kubernetes.yaml

kubectl port-forward "$(kubectl get pods --selector=app=scp -o name)" 5552:5552