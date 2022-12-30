locals {
    region = "us-west-2"
    bucket = "jmgilman-kiada-example"
    lock = "jmgilman-kiada-example"
    env = split("/", path_relative_to_include())[0]
    name = split("/", path_relative_to_include())[1]
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

generate "provider" {
  path = "provider.tf"
  if_exists = "overwrite"
  contents = <<EOF
provider "aws" {
  region = "${local.region}"
}
EOF
}

inputs = {
    label = {
        namespace = "jmgilman"
        environment = "kiada"
        stage = local.env
        name = local.name
    }
}