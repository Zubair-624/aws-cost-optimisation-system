#-----The Bucket Itself-----
resource "aws_s3_bucket" "s3" {

  # Bucket name must be globally unique across all AWS accounts worldwide
  # Appending account ID guarantees uniqueness
  bucket = "${var.project_name}-reports-${var.aws_account_id}"

  tags = {
    Name = "${var.project_name}-reports-${var.aws_account_id}"
  }
}

#-----Block All Public Access-----
resource "aws_s3_bucket_public_access_block" "s3" {

  bucket = aws_s3_bucket.s3.id

  block_public_acls       = true   
  block_public_policy     = true   
  ignore_public_acls      = true   
  restrict_public_buckets = true   
}

#-----Versioning-----
# Keeps history of every cost report uploaded
# Required for noncurrent_version_expiration to work
resource "aws_s3_bucket_versioning" "s3" {

  bucket = aws_s3_bucket.s3.id

  versioning_configuration {
    status = "Enabled"
  }
}

#-----Encryption at Rest-----
# All cost report JSON files encrypted using AES256 (free, AWS-managed key)
resource "aws_s3_bucket_server_side_encryption_configuration" "s3" {
  bucket = aws_s3_bucket.s3.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

#-----Lifecycle Rule-----
# Two rules:
# 1. expiration -> delete the actual cost report files after 180 days
# 2. noncurrent_version_expiration -> delete old versions after 90 days, (old versions exist because versioning is enabled above)
resource "aws_s3_bucket_lifecycle_configuration" "s3" {

  bucket = aws_s3_bucket.s3.id

  # Must wait for versioning to be enabled before applying lifecycle rules
  depends_on = [aws_s3_bucket_versioning.s3]

  rule {
    id     = "expire-old-reports"
    status = "Enabled"

    # Delete the actual cost report objects after 180 days
    expiration {
      days = 180
    }

    # Delete old versions of overwritten files after 90 days
    noncurrent_version_expiration {
      noncurrent_days = 90
    }
  }
  
}