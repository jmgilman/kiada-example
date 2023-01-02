variable "name" {
  type        = string
  description = "The name of the RDS instance"
}

variable "instance" {
  type        = string
  description = "The type of instance to use"
}

variable "storage" {
  type        = number
  description = "The amount of storage to provision"
}

variable "storage_max" {
  type        = number
  description = "The max amount of storage to provision"
}

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC to use"
}

variable "vpc_subnet_group" {
  type        = string
  description = "The name of the database subnet group to use"
}

variable "vpc_cidr" {
  type        = string
  description = "The CIDR of the VPC"
}

variable "username" {
  type        = string
  description = "The username to use for the master user"
  default     = "root"
}

variable "engine" {
  type        = string
  description = "The database engine to configure"
  default     = "postgres"
}

variable "engine_family" {
  type        = string
  description = "The database engine family"
  default     = "postgres14"
}

variable "engine_version" {
  type        = string
  description = "The database engine version to use"
  default     = "14"
}

variable "engine_major_version" {
  type        = string
  description = "The database engine major version to use"
  default     = "14"
}

variable "deletion_protection" {
  type        = bool
  description = "If true, prevents the RDS instance from being deleted"
  default     = false
}

variable "label" {
  type = object({
    namespace   = optional(string)
    environment = optional(string)
    stage       = optional(string)
    name        = optional(string)
    attributes  = optional(list(string))
    delimiter   = optional(string)
    tags        = optional(map(string))
  })
  description = "The label to use for this module"
}
