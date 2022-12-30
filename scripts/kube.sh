#!/usr/bin/env bash

CLUSTER_NAME=$(cd "${PRJ_ROOT}/src/infra/dev/kubernetes" && terragrunt output -json | jq -r .eks.value.cluster_name)

aws eks --region "${AWS_REGION}" update-kubeconfig --name "${CLUSTER_NAME}"
