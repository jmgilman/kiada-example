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

module "external_secrets_irsa_role" {
  # v5.9.2
  source = "github.com/terraform-aws-modules/terraform-aws-iam//modules/iam-role-for-service-accounts-eks?ref=cb074e72f38dd969e1a8dc5a1bdd0f647ab666cd"

  role_name                             = var.role_name
  attach_external_secrets_policy        = true
  external_secrets_secrets_manager_arns = ["arn:aws:secretsmanager:*:*:secret:${var.environment}/*"]

  oidc_providers = {
    ex = {
      provider_arn               = var.oidc_provider_arn
      namespace_service_accounts = ["${var.namespace}:${var.service_account_name}"]
    }
  }

  tags = module.label.tags
}

resource "kubernetes_service_account" "external-secrets-controller" {
  metadata {
    name      = var.service_account_name
    namespace = var.namespace

    labels = {
      "app.kubernetes.io/component" = "controller"
      "app.kubernetes.io/name"      = var.service_account_name
    }

    annotations = {
      "eks.amazonaws.com/role-arn" = module.external_secrets_irsa_role.iam_role_arn
    }
  }
  automount_service_account_token = true
}

resource "helm_release" "external-secrets-controller" {
  name       = "external-secrets-controller"
  namespace  = var.namespace
  wait       = true
  repository = "https://charts.external-secrets.io"
  chart      = "external-secrets"
  version    = var.chart_version

  set {
    name  = "installCRDs"
    value = "true"
  }
}

# Necessary because the "official" provider does not support using CRDs unless
# they already exist in the plan phase
# See: https://github.com/hashicorp/terraform-provider-kubernetes/issues/1367
resource "kubectl_manifest" "secret-store" {
  yaml_body = <<-EOF
    apiVersion: external-secrets.io/v1beta1
    kind: ClusterSecretStore
    metadata:
      name: cluster-secret-store
      namespace: ${var.namespace}
    spec:
      provider:
        aws:
          service: SecretsManager
          region: ${var.cluster_region}
          auth:
            jwt:
              serviceAccountRef:
                name: ${var.service_account_name}
                namespace: ${var.namespace}
  EOF

  depends_on = [
    kubernetes_service_account.external-secrets-controller,
    helm_release.external-secrets-controller
  ]
}
