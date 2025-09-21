# terraform {
#   backend "s3" {
#     bucket = "hw-tfstate-986397386508-eu-north-1"
#     key    = "hw-986397386508/terraform.tfstate"
#     region = "eu-north-1"
#     use_lockfile = true # new - native S3 locking
#     encrypt      = true
#   }
# }
