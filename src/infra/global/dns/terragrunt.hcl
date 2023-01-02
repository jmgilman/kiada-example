include "root" {
  path = find_in_parent_folders()
}

terraform {
    # See: https://github.com/gruntwork-io/terragrunt/issues/1675
    source = "../../modules/dns//."
}
