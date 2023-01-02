dependency "network" {
  config_path = "../network"

  mock_outputs = {
    vpc_id = "mock-id"
    vpc_cidr_block = "mock-cidr"
    private_subnets = []
    public_subnets = []
    database_subnet_group = "mock-subnet-group"
  }
  mock_outputs_allowed_terraform_commands = ["init", "validate"]
}