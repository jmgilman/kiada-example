#!/usr/bin/env bash

echo ">>> Generating new keys..."
LOCKBOX_MASTER_KEY=$(openssl rand -hex 32)
SECRET_KEY_BASE=$(openssl rand -hex 64)

echo ">>> Importing keys..."
kubectl create secret generic tooljet-server --from-literal=lockbox_key="${LOCKBOX_MASTER_KEY}" --from-literal=secret_key_base="${SECRET_KEY_BASE}"
