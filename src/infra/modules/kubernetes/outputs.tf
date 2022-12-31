output "eks" {
  description = "Outputs from the EKS module"
  value       = module.this
}

output "cluster_name" {
  description = "The name of the EKS cluster"
  value       = module.this.cluster_name
}

output "cluster_endpoint" {
  description = "Endpoint for the Kubernetes API server"
  value       = module.this.cluster_endpoint
}

output "cluster_certificate" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = module.this.cluster_certificate_authority_data
}

output "oidc_provider_arn" {
  description = "The ARN of the OIDC Provider"
  value       = module.this.oidc_provider_arn
}

output "oidc_provider" {
  description = "The OpenID Connect identity provider issuer URL"
  value       = module.this.oidc_provider
}
