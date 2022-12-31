variable "cluster_name" {
  type        = string
  description = "Name of the EKS cluster"
}

variable "cluster_region" {
  type        = string
  description = "The region the cluster is located in"
}

variable "role_arn" {
  type        = string
  description = "The ARN of the IAM role to use"
}

variable "service_account_name" {
  type        = string
  description = "The name to use for the AWS Load Balancer Controller service account"
}
