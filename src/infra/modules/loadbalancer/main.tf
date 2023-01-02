locals {
  namespace = "kube-system"
}

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

module "alb_controller_irsa_role" {
  # v5.9.2
  source = "github.com/terraform-aws-modules/terraform-aws-iam//modules/iam-role-for-service-accounts-eks?ref=cb074e72f38dd969e1a8dc5a1bdd0f647ab666cd"

  role_name                              = var.albc_role_name
  attach_load_balancer_controller_policy = true

  oidc_providers = {
    ex = {
      provider_arn               = var.oidc_provider_arn
      namespace_service_accounts = ["${local.namespace}:${var.albc_service_account_name}"]
    }
  }

  tags = module.label.tags
}

module "alb_controller" {
  source = "./modules/alb_controller"

  cluster_name         = var.cluster_name
  cluster_region       = var.cluster_region
  service_account_name = var.albc_service_account_name
  chart_version        = var.albc_chart_version

  namespace = local.namespace
  role_arn  = module.alb_controller_irsa_role.iam_role_arn
}

module "external_dns_irsa_role" {
  # v5.9.2
  source = "github.com/terraform-aws-modules/terraform-aws-iam//modules/iam-role-for-service-accounts-eks?ref=cb074e72f38dd969e1a8dc5a1bdd0f647ab666cd"

  role_name                     = var.edns_role_name
  attach_external_dns_policy    = true
  external_dns_hosted_zone_arns = var.edns_zones

  oidc_providers = {
    ex = {
      provider_arn               = var.oidc_provider_arn
      namespace_service_accounts = ["${local.namespace}:${var.edns_service_account_name}"]
    }
  }

  tags = module.label.tags
}

module "external_dns" {
  source = "./modules/external_dns"

  cluster_region       = var.cluster_region
  service_account_name = var.edns_service_account_name
  chart_version        = var.edns_chart_version

  namespace = local.namespace
  role_arn  = module.external_dns_irsa_role.iam_role_arn
}
