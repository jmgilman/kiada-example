#!/usr/bin/env bash

echo ">>> Fetching RDS info..."
RDS="$(cd "$PRJ_ROOT/src/infra/dev/database_cluster" && terragrunt output -json)"
PORT="$(echo "$RDS" | jq -r .port.value)"
ENDPOINT="$(echo "$RDS" | jq -r .endpoint.value)"

echo ">>> Starting socat..."
kubectl apply -f - <<-EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: socat
spec:
  selector:
    matchLabels:
      app: socat
  template:
    metadata:
      labels:
        app: socat
    spec:
      containers:
        - name: socat
          image: alpine/socat
          args:
            - "tcp-listen:${PORT},fork,reuseaddr"
            - "tcp-connect:${ENDPOINT}:${PORT}"
          ports:
            - containerPort: 5432
EOF

echo ">>> Waiting for deployment..."
kubectl wait deployment socat --for condition=Available=True

echo ">>> Forwarding database port..."
kubectl port-forward deployment/socat 5432 &
ID=$!

echo ">>> Waiting for proxy..."
sleep 5

echo ">>> Applying database module..."
cd "$PRJ_ROOT/src/infra/dev/database" && terragrunt apply -auto-approve

echo ">>> Stopping port-foward..."
kill $ID

echo ">>> Deleting socat deployment..."
kubectl delete deployment/socat
