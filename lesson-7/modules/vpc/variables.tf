variable "vpc_cidr_block" { type = string }
variable "public_subnets" { type = list(string) }
variable "private_subnets" { type = list(string) }
variable "availability_zones" { type = list(string) }
variable "vpc_name" { type = string }

variable "create_nat_per_az" {
  description = "Створювати по NAT GW на кожен AZ (true) або один NAT (false)"
  type        = bool
  default     = false
}
