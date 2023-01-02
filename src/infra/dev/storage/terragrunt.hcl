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
    cluster_region = "mock-region"
    cluster_endpoint = "mock-endpoint"
    cluster_certificate = "mock-certificate"

    oidc_provider_arn = "mock-arn"
  }
  mock_outputs_allowed_terraform_commands = ["init", "validate"]
}

terraform {
  # See: https://github.com/gruntwork-io/terragrunt/issues/1675
  source = "../../modules/storage//."
}

inputs = {
  cluster_name = dependency.kubernetes.outputs.cluster_name
  cluster_region = include.root.locals.region

  oidc_provider_arn = dependency.kubernetes.outputs.oidc_provider_arn
}

generate "provider_kube" {
  path = "provider_kube.tf"
  if_exists = "overwrite"
  contents = <<EOF
provider "kubernetes" {
  host                   = "${dependency.kubernetes.outputs.cluster_endpoint}"
  cluster_ca_certificate = base64decode("${dependency.kubernetes.outputs.cluster_certificate}")
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--region", "${include.root.locals.region}", "--cluster-name", "${dependency.kubernetes.outputs.cluster_name}"]
    command     = "aws"
  }
}

provider "helm" {
  kubernetes {
    host                   = "${dependency.kubernetes.outputs.cluster_endpoint}"
    cluster_ca_certificate = base64decode("${dependency.kubernetes.outputs.cluster_certificate}")
    exec {
        api_version = "client.authentication.k8s.io/v1beta1"
        args        = ["eks", "get-token", "--region", "${include.root.locals.region}", "--cluster-name", "${dependency.kubernetes.outputs.cluster_name}"]
        command     = "aws"
    }
  }
}
EOF
}