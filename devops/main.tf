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
  name = module.eks.cluster_name
  depends_on = [module.eks]
}

data "aws_eks_cluster_auth" "eks" {
  name = module.eks.cluster_name
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
  source                 = "./modules/jenkins"
  cluster_name          = module.eks.cluster_name
  oidc_provider_arn     = module.eks.oidc_provider_arn
  oidc_provider_url     = module.eks.oidc_provider_url
  github_pat            = var.github_pat
  github_user           = var.github_user
  github_repo_url       = var.github_repo_url
  depends_on            = [module.eks]

  providers = {
    helm = helm
    kubernetes = kubernetes
  }
}

module "argo_cd" {
  source       = "./modules/argo_cd"
  namespace    = "argocd"
  chart_version = "5.46.4"
  depends_on    = [module.eks]
}
