variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-north-1"
}

variable "backend_bucket_name" {
  description = "Назва S3 бакета для Terraform стейту (глобально унікальна)"
  type        = string
}

variable "vpc_cidr_block" {
  description = "CIDR для VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnets" {
  description = "CIDRи публічних підмереж"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_subnets" {
  description = "CIDRи приватних підмереж"
  type        = list(string)
  default     = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
}

variable "availability_zones" {
  description = "AZs"
  type        = list(string)
  default     = ["eu-north-1a", "eu-north-1b", "eu-north-1c"]
}

variable "create_nat_per_az" {
  description = "Створювати по NAT GW на кожен AZ (true) або один NAT (false)"
  type        = bool
  default     = false
}

variable "vpc_name" {
  description = "Ім'я VPC"
  type        = string
  default     = "lesson-5-vpc"
}

variable "ecr_name" {
  description = "Назва ECR репозиторію"
  type        = string
  default     = "lesson-5-ecr"
}

variable "scan_on_push" {
  description = "Увімкнути скан під час пушу"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Спільні теги"
  type        = map(string)
  default = {
    Project = "lesson-5"
    Owner   = "Kate Kurochka"
  }
}
