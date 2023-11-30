resource "random_string" "random_suffix" {
  length  = 3
  special = false
  upper   = false
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "terraform-state-${random_string.random_suffix.result}"

  # Prevent accidental deletion of this S3 Bucket
  lifecycle {
    prevent_destroy = false
  }
}

# Enable versioing so you can see the full revision history of your state file
resource "aws_s3_bucket_versioning" "enabled" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Enable server-side encryption by default
resource "aws_s3_bucket_server_side_encryption_configuration" "default" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Explicitly block akk public access to the s3 bucket
resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket                  = aws_s3_bucket.terraform_state.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


