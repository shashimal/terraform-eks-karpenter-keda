variable "name" {
  description = "Name of the VPC"
  type        = string
}

variable "cidr" {
  description = "VPC CIdR"
  type        = string
}

variable "public_subnets" {
  description = "Public subnet CIDR"
  type        = list(string)
}

variable "private_subnets" {
  description = "Public subnet CIDR"
  type        = list(string)
}

variable "azs" {
  description = "Availability zones"
  type        = list(string)
}
