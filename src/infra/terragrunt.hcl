remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite"
  }
  config = {
    bucket = "jmgilman-kiada-example"

    key = "${path_relative_to_include()}/terraform.tfstate"
    region         = "us-west-2"
    encrypt        = true
    dynamodb_table = "jmgilman-kiada-example"
  }
}

generate "provider" {
  path = "provider.tf"
  if_exists = "overwrite"
  contents = <<EOF
provider "aws" {
  region = "us-west-2"
}
EOF
}

generate "label" {
    path = "label.tf"
    if_exists = "overwrite"
    contents = <<EOF
locals {
  name = basename(abspath("$${path.module}"))
  env = basename(abspath("$${path.module}/.."))
}

module "label" {
  # v0.25.0
  source = "github.com/cloudposse/terraform-null-label?ref=488ab91e34a24a86957e397d9f7262ec5925586a"

  namespace   = "jmgilman"
  environment = "kiada"
  stage       = local.env
  name        = local.name
}
EOF
}