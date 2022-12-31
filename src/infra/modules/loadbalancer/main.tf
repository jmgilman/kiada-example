provider "kubernetes" {
  host                   = var.cluster_endpoint
  cluster_ca_certificate = base64decode(var.cluster_certificate)
  token                  = data.aws_eks_cluster_auth.this.token
}

provider "helm" {
  kubernetes {
    host                   = var.cluster_endpoint
    cluster_ca_certificate = base64decode(var.cluster_certificate)
    token                  = data.aws_eks_cluster_auth.this.token
  }
}

data "aws_eks_cluster_auth" "this" {
  name = var.cluster_name
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

module "load_balancer_controller_irsa_role" {
  # v5.9.2
  source = "github.com/terraform-aws-modules/terraform-aws-iam//modules/iam-role-for-service-accounts-eks?ref=cb074e72f38dd969e1a8dc5a1bdd0f647ab666cd"

  role_name                              = var.iam_role_name
  attach_load_balancer_controller_policy = true

  oidc_providers = {
    ex = {
      provider_arn               = var.oidc_provider_arn
      namespace_service_accounts = ["kube-system:${var.service_account_name}"]
    }
  }

  tags = module.label.tags
}

module "alb_controller" {
  source = "./modules/alb_controller"

  cluster_name         = var.cluster_name
  cluster_region       = var.cluster_region
  service_account_name = var.service_account_name

  role_arn = module.load_balancer_controller_irsa_role.iam_role_arn
}
