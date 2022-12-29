#!/usr/bin/env bash

# This script is intended to be used for quickly configuring credentials for
# temporary cloud environments provided by acloudguru.

set -e

echo ">>> Checking if existing session is valid..."
if
    ! aws-vault exec "${AWS_PROFILE}" -- aws sts get-caller-identity >/dev/null 2>&1
then
    echo ">>> Session has expired, deleting..."
    aws-vault remove -f "${AWS_PROFILE}"

    echo ">>> Please enter credentials for new session..."
    aws-vault add "${AWS_PROFILE}"
fi

echo ">>> Retrieving credentials..."
auth="$(aws-vault exec -n -j "${AWS_PROFILE}")"
AWS_ACCESS_KEY_ID="$(echo "${auth}" | jq -r .AccessKeyId)"
AWS_SECRET_ACCESS_KEY="$(echo "${auth}" | jq -r .SecretAccessKey)"

export AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY

echo ">>> Done!"
