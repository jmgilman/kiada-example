variable "cluster_name" {
  type        = string
  description = "Name of the EKS cluster"
}

variable "cluster_region" {
  type        = string
  description = "The region the cluster is located in"
}

variable "oidc_provider_arn" {
  type        = string
  description = "The ARN of the cluster OIDC provider"
}

variable "namespace" {
  type        = string
  description = "The namespace to deploy the cluster secret store to"
}

variable "environment" {
  type        = string
  description = "The name of the environment to scope secret access to"
}

variable "chart_version" {
  type        = string
  description = "The version of the external secrets chart to install"
}

variable "role_name" {
  type        = string
  description = "The name to use for the external secrets role"
  default     = "external-secrets-controller"
}

variable "service_account_name" {
  type        = string
  description = "The name to use for the external secrets service account"
  default     = "external-secrets-controller-irsa"
}

variable "label" {
  type = object({
    namespace   = optional(string)
    environment = optional(string)
    stage       = optional(string)
    name        = optional(string)
    attributes  = optional(list(string))
    delimiter   = optional(string)
    tags        = optional(map(string))
  })
  description = "The label to use for this module"
}
