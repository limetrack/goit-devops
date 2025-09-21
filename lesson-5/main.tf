provider "aws" {
  region = var.region
}

# ── S3 для бекапу стейту (bootstrap модуль)
module "s3_backend" {
  source      = "./modules/s3-backend"
  bucket_name = var.backend_bucket_name
}

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
