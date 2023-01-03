dependency "database_cluster" {
  config_path = "../database_cluster"

  mock_outputs = {
    id = "mock-id"
    endpoint = "mock-endpoint"
    port = 1234
    user = "mock-user"
    password = "mock-password"
    secret_arn = "mock-arn"
  }
  mock_outputs_allowed_terraform_commands = ["init", "validate"]
}

generate "db_versions" {
  path      = "db_versions.tf"
  if_exists = "overwrite"
  contents  = <<EOF
    terraform {
      required_providers {
        postgresql = {
          source = "cyrilgdn/postgresql"
          version = "1.18.0"
        }
      }
    }
EOF
}

generate "provider_db" {
  path = "provider_db.tf"
  if_exists = "overwrite"
  contents = <<EOF
locals {
    creds = jsondecode(data.aws_secretsmanager_secret_version.this.secret_string)
}

# Don't rely on state data for credentials as they may be subject to rotation
data "aws_secretsmanager_secret_version" "this" {
  secret_id = "${dependency.database_cluster.outputs.secret_arn}"
}

provider "postgresql" {
  host     = "127.0.0.1"
  username = local.creds.username
  port     = local.creds.port
  password = local.creds.password

  superuser = false
}
EOF
}