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

  # Tags to apply to all AWS resources by default
  default_tags {
    tags = {
      Owner     = "SRE"
      ManagedBy = "Terraform"
      Environment = "${title(split("/", path_relative_to_include())[0])}"
    }
  }
}
EOF
}