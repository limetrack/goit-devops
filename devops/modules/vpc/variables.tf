variable "vpc_cidr_block" {
  description = "VPC cidr block"
  type        = string
}

variable "vpc_name" {
  description = "Name of vpc"
  type        = string
}

variable "public_subnets" {
  description = "List of CIDR blocks for public subnets"
  type        = list(string)
}

variable "private_subnets" {
  description = "List of CIDR blocks for private_subnets subnets"
  type        = list(string)
}

variable "availability_zones"{
  description = "List of availability_zones"
  type        = list(string)
}

variable "create_nat_per_az" {
  description = "Створювати по NAT GW на кожен AZ (true) або один NAT (false)"
  type        = bool
  default     = false
}
