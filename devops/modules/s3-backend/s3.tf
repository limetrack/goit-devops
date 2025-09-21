# resource "aws_s3_bucket" "tf_state" {
#   bucket        = var.bucket_name
#   force_destroy = true

#   tags = {
#     Name        = "${var.bucket_name}"
#     Environment = "hw-986397386508"
#   }
# }

# resource "aws_s3_bucket_versioning" "tf_state_versioning" {
#   bucket = aws_s3_bucket.tf_state.id
#   versioning_configuration {
#     status = "Enabled"
#   }
# }

# resource "aws_s3_bucket_ownership_controls" "tf_state_ownership" {
#   bucket = aws_s3_bucket.tf_state.id
#   rule {
#     object_ownership = "BucketOwnerEnforced"
#   }
# }
