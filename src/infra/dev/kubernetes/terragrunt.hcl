include "root" {
  path = find_in_parent_folders()
}

dependency "network" {
  config_path = "../network"
}

locals {
    env = basename(abspath("$${path.module}/.."))
}

inputs = {
  cluster_name = "kiada-${local.env}"
  cluster_version = "1.24"

  cluster_desired_size = 2
  cluster_min_size = 1
  cluser_max_size = 3

  instance_types = ["t2.medium", "t3.medium"]

  vpc_id = dependency.network.outputs.vpc.vpc_id
  subnet_ids = dependency.network.outputs.vpc.private_subnets
}