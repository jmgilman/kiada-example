dependency "kubernetes" {
  config_path = "../kubernetes"

  mock_outputs = {
    cluster_name = "mock-cluster"
    cluster_endpoint = "mock-endpoint"
    cluster_certificate = "mock-certificate"

    oidc_provider_arn = "mock-arn"
    oidc_provider = "mock-provider"
  }
  mock_outputs_allowed_terraform_commands = ["init", "validate"]
}

generate "kube_versions" {
  path      = "kube_versions.tf"
  if_exists = "overwrite"
  contents  = <<EOF
    terraform {
      required_providers {
        kubectl = {
          source = "gavinbunney/kubectl"
          version = "1.14.0"
        }
      }
    }
EOF
}

generate "provider_kube" {
  path = "provider_kube.tf"
  if_exists = "overwrite"
  contents = <<EOF
provider "kubernetes" {
  host                   = "${dependency.kubernetes.outputs.cluster_endpoint}"
  cluster_ca_certificate = base64decode("${dependency.kubernetes.outputs.cluster_certificate}")
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", "${dependency.kubernetes.outputs.cluster_name}"]
    command     = "aws"
  }
}

provider "helm" {
  kubernetes {
    host                   = "${dependency.kubernetes.outputs.cluster_endpoint}"
    cluster_ca_certificate = base64decode("${dependency.kubernetes.outputs.cluster_certificate}")
    exec {
        api_version = "client.authentication.k8s.io/v1beta1"
        args        = ["eks", "get-token", "--cluster-name", "${dependency.kubernetes.outputs.cluster_name}"]
        command     = "aws"
    }
  }
}

provider "kubectl" {
  host                   = "${dependency.kubernetes.outputs.cluster_endpoint}"
  cluster_ca_certificate = base64decode("${dependency.kubernetes.outputs.cluster_certificate}")
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", "${dependency.kubernetes.outputs.cluster_name}"]
    command     = "aws"
  }
}
EOF
}