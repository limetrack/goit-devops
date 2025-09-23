terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.0.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.0"
    }
  }
}

provider "aws" {
  region = var.region
}

# ── S3 для бекапу стейту (bootstrap модуль)
# module "s3_backend" {
#   source      = "./modules/s3-backend"
#   bucket_name = var.backend_bucket_name
# }

# ── VPC: 3 публічні + 3 приватні підмережі, IGW, NAT GW, маршрути
module "vpc" {
  source             = "./modules/vpc"
  vpc_name           = var.vpc_name
  vpc_cidr_block     = var.vpc_cidr_block
  public_subnets     = var.public_subnets
  private_subnets    = var.private_subnets
  availability_zones = var.availability_zones
  create_nat_per_az  = var.create_nat_per_az
}

# ── ECR: репозиторій з авто-сканом
module "ecr" {
  source       = "./modules/ecr"
  ecr_name     = var.ecr_name
  scan_on_push = var.scan_on_push
}

# -- EKS: кластер
module "eks" {
  source        = "./modules/eks"
  cluster_name  = var.cluster_name
  subnet_ids    = module.vpc.public_subnet_ids
  instance_type = var.instance_type
}

data "aws_eks_cluster" "eks" {
  name       = module.eks.cluster_name
  depends_on = [module.eks]
}

data "aws_eks_cluster_auth" "eks" {
  name       = module.eks.cluster_name
  depends_on = [module.eks]
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.eks.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.eks.token
}

provider "helm" {
  kubernetes = {
    host                   = data.aws_eks_cluster.eks.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.eks.token
  }
}

module "jenkins" {
  source            = "./modules/jenkins"
  cluster_name      = module.eks.cluster_name
  oidc_provider_arn = module.eks.oidc_provider_arn
  oidc_provider_url = module.eks.oidc_provider_url
  github_pat        = var.github_pat
  github_user       = var.github_user
  github_repo_url   = var.github_repo_url
  depends_on        = [module.eks]

  providers = {
    helm       = helm
    kubernetes = kubernetes
  }
}

module "argo_cd" {
  source        = "./modules/argo_cd"
  namespace     = "argocd"
  chart_version = "5.46.4"
  depends_on    = [module.eks]
}

module "rds" {
  source = "./modules/rds"

  name                  = var.rds_name
  use_aurora            = var.rds_use_aurora
  aurora_instance_count = var.rds_aurora_instance_count

  # --- Aurora-only ---
  engine_cluster                = var.rds_engine_cluster
  engine_version_cluster        = var.rds_engine_version_cluster
  parameter_group_family_aurora = var.rds_parameter_group_family_aurora

  # --- RDS-only ---
  engine                     = var.rds_engine
  engine_version             = var.rds_engine_version
  parameter_group_family_rds = var.rds_parameter_group_family

  # Common
  instance_class          = var.rds_instance_class
  allocated_storage       = var.rds_allocated_storage
  db_name                 = var.rds_db_name
  username                = var.rds_username
  password                = var.rds_password
  subnet_private_ids      = module.vpc.private_subnet_ids
  subnet_public_ids       = module.vpc.public_subnet_ids
  publicly_accessible     = var.rds_publicly_accessible
  vpc_id                  = module.vpc.vpc_id
  vpc_cidr_block          = var.vpc_cidr_block
  multi_az                = var.rds_multi_az
  backup_retention_period = var.rds_backup_retention_period
  parameters              = var.rds_parameters

  tags = var.rds_tags
}

module "monitoring" {
  source        = "./modules/monitoring"
  namespace     = var.monitoring_namespace
  chart_version = var.monitoring_chart_version
  depends_on    = [module.eks]

  providers = {
    helm       = helm
    kubernetes = kubernetes
  }
}
