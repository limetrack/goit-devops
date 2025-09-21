region              = "eu-north-1"
backend_bucket_name = "lesson-5-tfstate-986397386508-eu-north-1"

vpc_cidr_block     = "10.0.0.0/16"
public_subnets     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
private_subnets    = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
availability_zones = ["eu-north-1a", "eu-north-1b", "eu-north-1c"]
create_nat_per_az  = false

vpc_name     = "lesson-5-vpc"
ecr_name     = "lesson-5-ecr"
scan_on_push = true
tags = {
  Project = "lesson-5", Owner = "Kate Kurochka"
}
