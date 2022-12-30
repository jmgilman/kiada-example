include "root" {
  path = find_in_parent_folders()
  expose = true
}

dependency "network" {
  config_path = "../network"

  mock_outputs = {
    vpc_id = "mock-id"
    private_subnets = []
  }
  mock_outputs_allowed_terraform_commands = ["init", "validate"]
}

terraform {
    # See: https://github.com/gruntwork-io/terragrunt/issues/1675
    source = "../../modules/kubernetes//."
}

inputs = {
  cluster_name = "kiada-${include.root.locals.env}"
  cluster_version = "1.24"

  cluster_desired_size = 2
  cluster_min_size = 1
  cluser_max_size = 3

  instance_types = ["t2.medium", "t3.medium"]

  vpc_id = dependency.network.outputs.vpc_id
  subnet_ids = dependency.network.outputs.private_subnets
}