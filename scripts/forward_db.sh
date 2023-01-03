#!/usr/bin/env bash

trap ctrl_c INT

function ctrl_c() {
    echo ">>> Stopping port-foward..."
    kill $ID

    echo ">>> Deleting socat deployment..."
    kubectl delete deployment/socat
}

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
kubectl port-forward deployment/socat "${PORT}" &
ID=$!

echo ">>> Database is accessible at localhost:${PORT}"
echo ">>> Press CTRL+C when done"
while true; do sleep 86400; done
