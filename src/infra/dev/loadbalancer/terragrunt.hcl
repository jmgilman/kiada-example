locals {
    env = split("/", path_relative_to_include())[0]
}

include "root" {
  path = find_in_parent_folders()
  expose = true
}

dependency "kubernetes" {
  config_path = "../kubernetes"

  mock_outputs = {
    cluster_name = "mock-cluster"
    cluster_endpoint = "mock-endpoint"
    cluster_certificate = "mock-certificate"

    oidc_provider_arn = "mock-arn"
    oidc_provider = "mock-provider"
  }
  mock_outputs_allowed_terraform_commands = ["init", "validate"]
}

terraform {
  # See: https://github.com/gruntwork-io/terragrunt/issues/1675
  source = "../../modules/loadbalancer//."
}

inputs = {
  cluster_name = dependency.kubernetes.outputs.cluster_name
  cluster_endpoint = dependency.kubernetes.outputs.cluster_endpoint
  cluster_certificate = dependency.kubernetes.outputs.cluster_certificate
  cluster_region = include.root.locals.region

  oidc_provider_arn = dependency.kubernetes.outputs.oidc_provider_arn
  oidc_provider = dependency.kubernetes.outputs.oidc_provider
}