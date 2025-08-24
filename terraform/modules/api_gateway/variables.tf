variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment (e.g., prod, staging)"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "private_subnets" {
  description = "List of private subnet IDs"
  type        = list(string)
}


variable "container_port" {
  description = "Port exposed by the container"
  type        = number
}

variable "nlb_listener_arn" {
  description = "ARN do listener do NLB"
  type        = string
}
