#!/usr/bin/env bash

OLD=$(kubectl config get-contexts -o name | grep 'arn:aws:eks:.*:cluster/kiada-dev')
if [[ -n "${OLD}" ]]; then
    echo ">>> Deleting old cluster..."
    kubectl config delete-context "${OLD}"
fi

echo ">>> Configuring new cluster..."
CLUSTER_NAME=$(cd "${PRJ_ROOT}/src/infra/dev/kubernetes" && terragrunt output -json | jq -r .eks.value.cluster_name)
aws eks --region "${AWS_REGION}" update-kubeconfig --name "${CLUSTER_NAME}"
