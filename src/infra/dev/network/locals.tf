# Generated by Terragrunt. Sig: nIlQXj57tbuaRZEa
locals {
  # Used for importing remote state
  region = "us-west-2"
  bucket = "jmgilman-kiada-example"
  lock = "jmgilman-kiada-example"

  # Used for labelling
  name = basename(abspath("${path.module}"))
  env = basename(abspath("${path.module}/.."))
}