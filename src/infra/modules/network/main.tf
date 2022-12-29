data "aws_availability_zones" "available" {
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

locals {
  azs = slice(data.aws_availability_zones.available.names, 0, var.azs)
}

module "this" {
  # v3.18.1
  source = "github.com/terraform-aws-modules/terraform-aws-vpc?ref=aa61bc4346e1c430df8ec163ae9799d57df4af20"

  name = var.label.id

  cidr = var.cidr
  azs  = local.azs

  public_subnets   = [for k, v in local.azs : cidrsubnet(var.cidr, var.subnet_bits, k)]
  private_subnets  = [for k, v in local.azs : cidrsubnet(var.cidr, var.subnet_bits, k + 10)]
  database_subnets = [for k, v in local.azs : cidrsubnet(var.cidr, var.subnet_bits, k + 20)]

  enable_nat_gateway = true

  tags = var.label.tags
}
