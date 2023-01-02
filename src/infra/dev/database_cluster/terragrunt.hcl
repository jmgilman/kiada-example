locals {
    env = split("/", path_relative_to_include())[0]
}

include "root" {
  path = find_in_parent_folders()
  expose = true
}

dependency "network" {
  config_path = "../network"

  mock_outputs = {
    vpc_id = "mock-id"
    vpc_cidr_block = "mock-cidr"
    database_subnet_group = "mock-subnet-group"
  }
  mock_outputs_allowed_terraform_commands = ["init", "validate"]
}

terraform {
    # See: https://github.com/gruntwork-io/terragrunt/issues/1675
    source = "../../modules/database_cluster//."
}

inputs = {
  name = "${local.env}-rds"
  instance = "db.t3.medium"

  storage = 20
  storage_max = 50

  vpc_id = dependency.network.outputs.vpc_id
  vpc_subnet_group = dependency.network.outputs.database_subnet_group
  vpc_cidr = dependency.network.outputs.vpc_cidr_block
}