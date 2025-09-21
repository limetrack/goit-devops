#-------------Backend-----------------
output "s3_backend" {
  description = "S3 для бекенду"
  value = {
    bucket_name = module.s3_backend.s3_bucket_name
  }
}

#-------------VPC-----------------
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

#-------------ECR-----------------
output "ecr" {
  description = "Результати по ECR"
  value = {
    repository_name = module.ecr.repository_name
    repository_url  = module.ecr.repository_url
  }
}

#-------------EKS-----------------
output "eks_cluster_endpoint" {
  description = "EKS API endpoint for connecting to the cluster"
  value       = module.eks.eks_cluster_endpoint
}

output "eks_cluster_name" {
  description = "Name of the EKS cluster"
  value       = module.eks.eks_cluster_name
}

output "eks_node_role_arn" {
  description = "IAM role ARN for EKS Worker Nodes"
  value       = module.eks.eks_node_role_arn
}
