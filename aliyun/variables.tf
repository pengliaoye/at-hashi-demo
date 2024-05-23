variable "first_name" {
  type        = string
  description = "Please enter your first name. This will be used in several components."
  default = "hashistack"
}

variable "atcomputing_user" {
  type        = string
  description = "The user created on the EC2 instance."
  default     = "atcomputing"
}

variable "public_key" {
  type    = string
  default = "~/.ssh/id_rsa.pub"
}

variable "private_key" {
  type    = string
  default = "~/.ssh/id_rsa"
}

variable "instance_type" {
  type    = string
  default = "ecs.g7.large"
}

variable "server_count" {
  type    = number
  default = 3
}

variable "server_name_prefix" {
  type    = string
  default = "server"
}

variable "client_count" {
  type    = number
  default = 4
}

variable "client_name_prefix" {
  type    = string
  default = "client"
}

