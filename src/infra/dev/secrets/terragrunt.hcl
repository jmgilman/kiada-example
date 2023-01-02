include "root" {
  path = find_in_parent_folders()
  expose = true
}

include "common" {
    path = find_in_parent_folders("common.hcl")
    expose = true
}

include "kubernetes" {
    path = find_in_parent_folders("kubernetes.hcl")
}

terraform {
  # See: https://github.com/gruntwork-io/terragrunt/issues/1675
  source = "../../modules/secrets//."
}

inputs = {
  cluster_name = dependency.kubernetes.outputs.cluster_name
  cluster_region = include.root.locals.region

  oidc_provider_arn = dependency.kubernetes.outputs.oidc_provider_arn

  namespace = "kube-system"
  environment = include.common.locals.env
  chart_version = "0.7.0"
}