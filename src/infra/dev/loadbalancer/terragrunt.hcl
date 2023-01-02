include "root" {
  path = find_in_parent_folders()
  expose = true
}

include "kubernetes" {
    path = find_in_parent_folders("kubernetes.hcl")
}

include "dns" {
    path = find_in_parent_folders("dns.hcl")
}

terraform {
  # See: https://github.com/gruntwork-io/terragrunt/issues/1675
  source = "../../modules/loadbalancer//."
}

inputs = {
  cluster_name = dependency.kubernetes.outputs.cluster_name
  cluster_region = include.root.locals.region

  oidc_provider_arn = dependency.kubernetes.outputs.oidc_provider_arn

  albc_chart_version = "1.4.6"

  edns_zones = [for domain, id in dependency.dns.outputs.zone_arn : id]
  edns_chart_version = "6.12.2"
}