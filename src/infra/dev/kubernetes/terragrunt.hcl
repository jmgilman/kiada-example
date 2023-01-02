include "root" {
  path = find_in_parent_folders()
}

include "common" {
    path = find_in_parent_folders("common.hcl")
    expose = true
}

include "network" {
    path = find_in_parent_folders("network.hcl")
}

terraform {
    # See: https://github.com/gruntwork-io/terragrunt/issues/1675
    source = "../../modules/kubernetes//."
}

inputs = {
  cluster_name = "kiada-${include.common.locals.env}"
  cluster_version = "1.24"

  cluster_desired_size = 2
  cluster_min_size = 1
  cluser_max_size = 3

  instance_types = ["t2.medium", "t3.medium"]

  vpc_id = dependency.network.outputs.vpc_id
  subnet_ids = dependency.network.outputs.private_subnets
}