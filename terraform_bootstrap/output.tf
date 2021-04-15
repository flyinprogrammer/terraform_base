output "terraform_state_backend_bucket" {
  value = aws_s3_bucket.default.id
}

output "terraform_state_backend_kms_key_id" {
  value = aws_kms_key.default.arn
}

