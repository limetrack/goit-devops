#-------------Backend-----------------
# output "s3_backend" {
#   description = "S3 for backend"
#   value = {
#     bucket_name = module.s3_backend.s3_bucket_name
#   }
# }

#-------------VPC-----------------
output "vpc" {
  description = "VPC outputs"
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
  description = "ECR outputs"
  value = {
    repository_arn = module.ecr.repository_arn
    repository_url = module.ecr.repository_url
  }
}

#-------------EKS-----------------
output "cluster_endpoint" {
  description = "EKS API endpoint for connecting to the cluster"
  value       = module.eks.cluster_endpoint
}

output "cluster_name" {
  description = "Name of the EKS cluster"
  value       = module.eks.cluster_name
}

output "eks_node_role_arn" {
  description = "IAM role ARN for EKS Worker Nodes"
  value       = module.eks.eks_node_role_arn
}

output "oidc_provider_arn" {
  description = "OIDC Provider ARN"
  value       = module.eks.oidc_provider_arn
}

output "oidc_provider_url" {
  description = "OIDC Provider URL"
  value       = module.eks.oidc_provider_url
}

#-------------Jenkins-----------------
output "jenkins_release" {
  value = module.jenkins.jenkins_release_name
}

output "jenkins_namespace" {
  value = module.jenkins.jenkins_namespace
}

#-------------ArgoCD-----------------
output "argocd_namespace" {
  description = "ArgoCD namespace"
  value       = module.argo_cd.namespace
}

output "argocd_server_service" {
  description = "ArgoCD server service"
  value       = module.argo_cd.argo_cd_server_service
}

output "argocd_admin_password" {
  description = "Initial admin password"
  value       = module.argo_cd.admin_password
}