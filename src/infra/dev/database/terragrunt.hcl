include "root" {
  path = find_in_parent_folders()
}

include "common" {
    path = find_in_parent_folders("common.hcl")
    expose = true
}

include "database" {
    path = find_in_parent_folders("database.hcl")
}

terraform {
    # See: https://github.com/gruntwork-io/terragrunt/issues/1675
    source = "../../modules/database//."
}

inputs = {
    databases = [
        "wordpress"
    ]
    db_instance_id = dependency.database_cluster.outputs.id
    environment = include.common.locals.env
}