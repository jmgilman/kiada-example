output "id" {
  description = "The RDS instance ID"
  value       = module.db.db_instance_id
}

output "endpoint" {
  description = "The connection endpoint"
  value       = split(":", module.db.db_instance_endpoint)[0]
}

output "port" {
  description = "The database port"
  value       = module.db.db_instance_port
}

output "user" {
  description = "The master username for the database"
  value       = module.db.db_instance_password
  sensitive   = true
}

output "password" {
  description = "The master password for the database"
  value       = module.db.db_instance_password
  sensitive   = true
}

output "secret_arn" {
  description = "The ARN of the secret containing root connection details"
  value       = aws_secretsmanager_secret.this.arn
}
