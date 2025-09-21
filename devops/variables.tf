variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-north-1"
}

# variable "backend_bucket_name" {
#   description = "S3 bucket name for Terraform state (globally unique)"
#   type        = string
# }

variable "vpc_cidr_block" {
  description = "CIDR for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnets" {
  description = "CIDRs for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_subnets" {
  description = "CIDRs for private subnets"
  type        = list(string)
  default     = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
}

variable "availability_zones" {
  description = "AZs"
  type        = list(string)
  default     = ["eu-north-1a", "eu-north-1b", "eu-north-1c"]
}

variable "create_nat_per_az" {
  description = "Create NAT GW per AZ (true) or single NAT (false)"
  type        = bool
  default     = false
}

variable "vpc_name" {
  description = "VPC name"
  type        = string
  default     = "hw-986397386508-vpc"
}

variable "ecr_name" {
  description = "ECR repository name"
  type        = string
  default     = "hw-986397386508-ecr"
}

variable "scan_on_push" {
  description = "Enable scan on push"
  type        = bool
  default     = true
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  default     = "hw-986397386508-eks-cluster"
}

variable "instance_type" {
  description = "EC2 instance type for the worker nodes"
  default     = "t3.medium" #  "t2.micro"
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default = {
    Project = "lesson-9"
    Owner   = "Kate Kurochka"
  }
}

// github credentials
variable "github_pat" {
  description = "GitHub Personal Access Token"
  type        = string
}
variable "github_user" {
  description = "GitHub username"
  type        = string
}
variable "github_repo_url" {
  description = "GitHub repository name"
  type        = string
}
