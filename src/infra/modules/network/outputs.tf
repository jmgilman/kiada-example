output "vpc" {
  description = "Outputs from the VPC module"
  value       = module.this
}

output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.this.vpc_id
}

output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = module.this.private_subnets
}

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = module.this.public_subnets
}
