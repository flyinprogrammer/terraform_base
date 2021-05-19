data "aws_iam_policy_document" "s3_default" {
  statement {
    sid       = "DenyUnEncryptedObjectUploads"
    effect    = "Deny"
    actions   = ["s3:PutObject"]
    resources = ["arn:aws:s3:::${var.bucket_name}/*"]
    principals {
      identifiers = ["*"]
      type        = "*"
    }
    condition {
      test     = "StringNotEquals"
      values   = ["aws:kms"]
      variable = "s3:x-amz-server-side-encryption"
    }
  }
  statement {
    sid       = "RequiresKMSEncryption"
    effect    = "Deny"
    actions   = ["s3:PutObject"]
    resources = ["arn:aws:s3:::${var.bucket_name}/*"]
    principals {
      identifiers = ["*"]
      type        = "*"
    }
    condition {
      test     = "StringNotLikeIfExists"
      values   = [aws_kms_key.default.arn]
      variable = "s3:x-amz-server-side-encryption-aws-kms-key-id"
    }
  }
  statement {
    sid    = "RequireCorrectBucketOwner"
    effect = "Deny"
    actions = [
      "s3:PutObject",
      "s3:PutObjectAcl"
    ]
    resources = ["arn:aws:s3:::${var.bucket_name}/*"]
    principals {
      identifiers = ["*"]
      type        = "*"
    }
    condition {
      test     = "StringNotEquals"
      values   = ["bucket-owner-full-control"]
      variable = "s3:x-amz-acl"
    }
  }
}

resource "aws_kms_key" "default" {
  description             = "${var.bucket_name} KMS Key"
  deletion_window_in_days = 10
}

resource "aws_s3_bucket" "default" {
  bucket = var.bucket_name
  acl    = "private"

  versioning {
    enabled = true
  }

  lifecycle_rule {
    enabled                                = true
    prefix                                 = "terraform_remote_state/"
    abort_incomplete_multipart_upload_days = 7
    expiration {
      expired_object_delete_marker = true
    }
    noncurrent_version_expiration {
      days = 14
    }
  }

  policy = data.aws_iam_policy_document.s3_default.json
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "aws:kms"
        kms_master_key_id = aws_kms_key.default.id
      }
    }
  }
}

resource "aws_s3_bucket_public_access_block" "default" {
  bucket = aws_s3_bucket.default.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


resource "aws_s3_bucket_ownership_controls" "example" {
  bucket = aws_s3_bucket.default.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_dynamodb_table" "default" {
  name         = var.dynamodb_table_name
  hash_key     = "LockID"
  billing_mode = "PAY_PER_REQUEST"

  server_side_encryption {
    enabled     = true
    kms_key_arn = aws_kms_key.default.arn
  }

  attribute {
    name = "LockID"
    type = "S"
  }
}
