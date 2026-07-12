#-----S3 Bucket Name-----
# Passed to Lambda as S3_BUCKET environment variable
# cost_collector Lambda uses this to know where to upload cost reports
output "bucket_name" {
  value = aws_s3_bucket.s3.id
}

#-----S3 Bucket ARN-----
# Used in IAM policy to grant Lambda s3:PutObject and s3:GetObject permissions
output "bucket_arn" {
  value = aws_s3_bucket.s3.arn
}