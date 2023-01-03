module "label" {
  # v0.25.0
  source = "github.com/cloudposse/terraform-null-label?ref=488ab91e34a24a86957e397d9f7262ec5925586a"

  namespace   = var.label.namespace
  environment = var.label.environment
  stage       = var.label.stage
  name        = var.label.name
  attributes  = var.label.attributes
  delimiter   = var.label.delimiter
  tags        = var.label.tags
}

data "aws_db_instance" "database" {
  db_instance_identifier = var.db_instance_id
}

resource "random_password" "this" {
  for_each = toset(var.databases)
  length   = 16
  special  = false
}

resource "postgresql_role" "this" {
  for_each = toset(var.databases)

  name     = each.value
  password = random_password.this[each.value].result

  login = true
}

resource "postgresql_database" "database" {
  for_each = toset(var.databases)

  name              = each.value
  owner             = postgresql_role.this[each.value].name
  lc_collate        = "C"
  connection_limit  = -1
  allow_connections = true
}

resource "aws_secretsmanager_secret" "this" {
  for_each = toset(var.databases)

  name = "${var.environment}/db/${each.value}"
  tags = module.label.tags
}

resource "aws_secretsmanager_secret_version" "this" {
  for_each = toset(var.databases)

  secret_id = aws_secretsmanager_secret.this[each.value].id
  secret_string = jsonencode({
    username             = postgresql_role.this[each.value].name
    password             = random_password.this[each.value].result
    engine               = data.aws_db_instance.database.engine
    host                 = data.aws_db_instance.database.endpoint
    port                 = data.aws_db_instance.database.port
    dbInstanceIdentifier = var.db_instance_id
  })
}
