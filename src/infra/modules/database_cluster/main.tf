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

module "security_group" {
  # v4.16.2
  source = "github.com/terraform-aws-modules/terraform-aws-security-group?ref=700f32c275e2367a766f4c2824d31d7669a91a00"

  name        = "RDSAccessForVPC"
  description = "Allows access to RDS instance from within VPC"
  vpc_id      = var.vpc_id

  # ingress
  ingress_with_cidr_blocks = [
    {
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      description = "PostgreSQL access from within VPC"
      cidr_blocks = var.vpc_cidr
    },
  ]

  tags = module.label.tags
}

module "db" {
  # v5.2.2
  source = "github.com/terraform-aws-modules/terraform-aws-rds?ref=501f0ac85988126b1ea2011faf858e64b67293ce"

  identifier = var.name

  engine               = var.engine
  engine_version       = var.engine_version
  family               = var.engine_family
  major_engine_version = var.engine_major_version
  instance_class       = var.instance

  allocated_storage     = var.storage
  max_allocated_storage = var.storage_max

  username = var.username

  multi_az               = true
  db_subnet_group_name   = var.vpc_subnet_group
  vpc_security_group_ids = [module.security_group.security_group_id]

  backup_retention_period = 30

  enabled_cloudwatch_logs_exports = ["postgresql"]
  create_cloudwatch_log_group     = true

  performance_insights_enabled          = true
  performance_insights_retention_period = 7
  create_monitoring_role                = true
  monitoring_interval                   = 60
  monitoring_role_name                  = "enhanced-monitoring-role"
  monitoring_role_use_name_prefix       = true
  monitoring_role_description           = "Provides access for ${var.name} RDS instance to export enhanced monitoring"

  deletion_protection = var.deletion_protection

  tags = module.label.tags
}

resource "aws_secretsmanager_secret" "this" {
  name = "${var.environment}/db/root_account"
  tags = module.label.tags
}

resource "aws_secretsmanager_secret_version" "this" {
  secret_id = aws_secretsmanager_secret.this.id
  secret_string = jsonencode({
    username             = module.db.db_instance_username
    password             = module.db.db_instance_password
    engine               = module.db.db_instance_engine
    host                 = split(":", module.db.db_instance_endpoint)[0]
    port                 = module.db.db_instance_port
    dbInstanceIdentifier = module.db.db_instance_id
  })
}
