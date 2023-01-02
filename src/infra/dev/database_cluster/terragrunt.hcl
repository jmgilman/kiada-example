include "root" {
  path = find_in_parent_folders()
  expose = true
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
    source = "../../modules/database_cluster//."
}

inputs = {
  name = "${include.common.locals.env}-rds"
  instance = "db.t3.medium"

  storage = 20
  storage_max = 50

  vpc_id = dependency.network.outputs.vpc_id
  vpc_subnet_group = dependency.network.outputs.database_subnet_group
  vpc_cidr = dependency.network.outputs.vpc_cidr_block
}