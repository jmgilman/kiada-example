locals {
    region = "us-west-2"
    bucket = "jmgilman-kiada-example"
    lock = "jmgilman-kiada-example"
}

remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite"
  }
  config = {
    bucket = local.bucket

    key = "${path_relative_to_include()}/terraform.tfstate"
    region         = local.region
    encrypt        = true
    dynamodb_table = local.lock
  }
}

generate "locals" {
    path = "locals.tf"
    if_exists = "overwrite"
    contents = <<EOF
locals {
  # Used for importing remote state
  region = "${local.region}"
  bucket = "${local.bucket}"
  lock = "${local.lock}"

  # Used for labelling
  name = basename(abspath("$${path.module}"))
  env = basename(abspath("$${path.module}/.."))
}
EOF
}

generate "provider" {
  path = "provider.tf"
  if_exists = "overwrite"
  contents = <<EOF
provider "aws" {
  region = local.region
}
EOF
}

generate "label" {
    path = "label.tf"
    if_exists = "overwrite"
    contents = <<EOF
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