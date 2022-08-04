variable "name" {
  description = "(Required) Cluster name."
}

variable "environment" {
  default = "PRODUCTION"
  description = "(Optional) Deployment environment of the Kafka cluster. Can be either PRESTABLE or PRODUCTION."
}

variable "network_id" {
  description = "(Required) ID of the network, to which the Kafka cluster belongs."
}

variable "subnet_ids" {
  default = null
  description = "(Optional) IDs of the subnets, to which the Kafka cluster belongs."
}

variable "config" {
  default = {}
  description = "(Required) Configuration of the Kafka cluster. The structure is documented below."
}

variable "users" {
  default = []
  description = "(Optional) A user of the Kafka cluster."
}

variable "topics" {
  default = []
  description = "(Optional) Kafka topics to create with configuration."
}

variable "default_security_group_ingress" {
  default = []
  description = "(Optional) - A list of ingress rules to create with default security group."
}

variable "default_security_group_egress" {
  default = []
  description = "(Optional) - A list of egress rules to create with default security group."
}

variable "create_default_security_group" {
  default = false
  description = "(Optional) - Create default security group."
}

variable "vpc_security_groups" {
  default = []
  description = "(Optional) - Assign security groups to instance."
}
