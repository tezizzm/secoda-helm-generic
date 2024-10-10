#!/bin/bash

kubectl create namespace secoda
kubectl config set-context --current --namespace=secoda

# Replace docker password with Secoda-provided value
kubectl create secret docker-registry secoda-dockerhub \
  --docker-email=carter@secoda.co \
  --docker-username=secodaonpremise \
  --docker-password=REPLACE_WITH_SECODA_PROVIDED \
  --docker-server=https://index.docker.io/v1/

# Generate the internal SSL keys
PRIVKEY=$(openssl genrsa -traditional 2048 | base64)
PUBKEY=$(echo $PRIVKEY | base64 -d | openssl rsa -outform PEM -pubout | base64)
kubectl create secret generic secoda-secret-keys \
    --from-literal=PRIVATE_KEY=$PRIVKEY \
    --from-literal=PUBLIC_KEY=$PUBKEY


# Edit the secrets.env file to set your secrets values
kubectl create secret generic secoda-secrets \
    --from-env-file=secoda-secrets.env

