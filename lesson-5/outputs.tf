output "s3_backend" {
  description = "S3 для бекенду"
  value = {
    bucket_name = module.s3_backend.s3_bucket_name
  }
}

output "vpc" {
  description = "Результати по VPC"
  value = {
    vpc_id             = module.vpc.vpc_id
    igw_id             = module.vpc.igw_id
    public_subnet_ids  = module.vpc.public_subnet_ids
    private_subnet_ids = module.vpc.private_subnet_ids
    nat_gateway_ids    = module.vpc.nat_gateway_ids
  }
}

output "ecr" {
  description = "Результати по ECR"
  value = {
    repository_name = module.ecr.repository_name
    repository_url  = module.ecr.repository_url
  }
}
