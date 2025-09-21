terraform {
  backend "s3" {
    bucket = "lesson-7-tfstate-986397386508-eu-north-1"
    key    = "lesson-7/terraform.tfstate"
    region = "eu-north-1"
    # dynamodb_table = "terraform-locks"  # old param
    use_lockfile = true # new - native S3 locking
    encrypt      = true
  }
}
