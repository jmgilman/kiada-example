data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = local.bucket
    region = local.region
    key    = "${local.env}/network/terraform.tfstate"
  }
}

locals {
  vpc_id     = data.terraform_remote_state.network.outputs.vpc.vpc_id
  subnet_ids = data.terraform_remote_state.network.outputs.vpc.private_subnets
}

module "kubernetes" {
  source = "../../modules/kubernetes"

  cluster_name    = "kiada-${local.env}"
  cluster_version = "1.24"

  vpc_id     = local.vpc_id
  subnet_ids = local.subnet_ids

  label = module.label
}
