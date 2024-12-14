output "bucket_name" {
  description = "The name of the S3 bucket"
  value       = aws_s3_bucket.s3_bucket.bucket
}

output "bucket_arn" {
  description = "The ARN of the S3 bucket"
  value       = aws_s3_bucket.s3_bucket.arn
}

output "bucket_region" {
  description = "The region of the S3 bucket"
  value       = aws_s3_bucket.s3_bucket.region
}