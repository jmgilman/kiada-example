variable "cidr" {
  type        = string
  description = "The CIDR block to use for the VPC"
}

variable "subnet_bits" {
  type        = number
  description = "Number of bits to augment the CIDR with for creating subnets"
}

variable "azs" {
  type        = number
  description = "The number of availability zones to use (one subnet per az is created)"
}
