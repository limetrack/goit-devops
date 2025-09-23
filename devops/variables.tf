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

# RDS / Aurora
variable "rds_name" {
  description = "RDS instance name"
  type        = string
  default     = "myapp-db"
}

variable "rds_use_aurora" {
  description = "Use Aurora cluster instead of regular RDS"
  type        = bool
  default     = false
}

variable "rds_aurora_instance_count" {
  description = "Number of Aurora instances"
  type        = number
  default     = 2
}

variable "rds_engine" {
  description = "Database engine"
  type        = string
  default     = "postgres"
}

variable "rds_engine_version" {
  description = "Database engine version"
  type        = string
  default     = "17.2"
}

variable "rds_parameter_group_family" {
  description = "DB parameter group family"
  type        = string
  default     = "postgres17"
}

variable "rds_engine_cluster" {
  description = "Aurora cluster engine"
  type        = string
  default     = "aurora-postgresql"
}

variable "rds_engine_version_cluster" {
  description = "Aurora cluster engine version"
  type        = string
  default     = "15.3"
}

variable "rds_parameter_group_family_aurora" {
  description = "Aurora cluster parameter group family"
  type        = string
  default     = "aurora-postgresql15"
}

variable "rds_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.medium"
}

variable "rds_allocated_storage" {
  description = "Allocated storage for RDS instance"
  type        = number
  default     = 20
}

variable "rds_db_name" {
  description = "Database name"
  type        = string
  default     = "myapp"
}

variable "rds_username" {
  description = "Database username"
  type        = string
  default     = "postgres"
}

variable "rds_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

variable "rds_publicly_accessible" {
  description = "Whether RDS instance is publicly accessible"
  type        = bool
  default     = true
}

variable "rds_multi_az" {
  description = "Enable multi-AZ deployment"
  type        = bool
  default     = true
}

variable "rds_backup_retention_period" {
  description = "Backup retention period in days"
  type        = number
  default     = 7
}

variable "rds_parameters" {
  description = "Database parameters"
  type        = map(string)
  default = {
    max_connections            = "200"
    log_min_duration_statement = "500"
  }
}

variable "rds_tags" {
  description = "Tags for RDS resources"
  type        = map(string)
  default = {
    Environment = "dev"
    Project     = "myapp"
  }
}

# Monitoring
variable "monitoring_namespace" {
  description = "Kubernetes namespace for monitoring stack"
  type        = string
  default     = "monitoring"
}

variable "monitoring_chart_version" {
  description = "Version of kube-prometheus-stack Helm chart"
  type        = string
  default     = "55.5.0"
}
