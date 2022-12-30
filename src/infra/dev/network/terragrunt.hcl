include "root" {
  path = find_in_parent_folders()
}

terraform {
    # See: https://github.com/gruntwork-io/terragrunt/issues/1675
    source = "../../modules/network//."
}

inputs = {
  cidr        = "10.0.0.0/16"
  subnet_bits = 8
  azs         = 3
}