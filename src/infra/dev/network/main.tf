module "network" {
  source = "../../modules/network"

  cidr        = var.cidr
  subnet_bits = var.subnet_bits
  azs         = var.azs
  label       = module.label
}
