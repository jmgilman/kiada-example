variable "databases" {
  type        = list(string)
  description = "A list of databases to create"
}

variable "db_instance_id" {
  type        = string
  description = "The instance ID of the RDS database"
}

variable "environment" {
  type        = string
  description = "The name of the environment to scope secret access to"
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
