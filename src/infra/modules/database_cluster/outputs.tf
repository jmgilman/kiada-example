output "vpc" {
  description = "Outputs from the RDS module"
  value       = module.db
  sensitive   = true
}
