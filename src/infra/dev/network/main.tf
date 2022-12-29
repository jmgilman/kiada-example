module "network" {
  source = "../../modules/network"

  cidr        = "10.0.0.0/16"
  subnet_bits = 8
  azs         = 3
  label       = module.label
}
