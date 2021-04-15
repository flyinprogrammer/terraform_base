data "aws_caller_identity" "default" {}

data "aws_iam_policy_document" "kms" {
  statement {
    sid    = "Enable IAM User Permissions"
    effect = "Allow"
    principals {
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.default.account_id}:root"]
      type        = "AWS"
    }
    actions   = ["kms:*"]
    resources = ["*"]
  }
  statement {
    sid    = "Allow Cloudwatch Logs"
    effect = "Allow"
    principals {
      identifiers = ["logs.${var.region}.amazonaws.com"]
      type        = "Service"
    }
    actions = [
      "kms:Encrypt*",
      "kms:Decrypt*",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:Describe*"
    ]
    resources = ["*"]
    condition {
      test     = "ArnEquals"
      values   = [local.smsLogGroupArn]
      variable = "kms:EncryptionContext:aws:logs:arn"
    }
  }
}

resource "aws_kms_key" "default" {
  deletion_window_in_days = 7
  description             = "Key for SSM stuff"
  policy                  = data.aws_iam_policy_document.kms.json
}

resource "aws_cloudwatch_log_group" "default" {
  name              = local.ssmLogGroupName
  kms_key_id        = aws_kms_key.default.arn
  retention_in_days = 7
}

locals {
  ssmLogGroupName = "AWSSSMSessions"
  smsLogGroupArn  = "arn:aws:logs:${var.region}:${data.aws_caller_identity.default.account_id}:log-group:${local.ssmLogGroupName}"
  ssmrunshell = {
    "schemaVersion" : "1.0",
    "description" : "Document to hold regional settings for Session Manager",
    "sessionType" : "Standard_Stream",
    "inputs" : {
      "s3BucketName" : "",
      "s3KeyPrefix" : "",
      "s3EncryptionEnabled" : true,
      "cloudWatchLogGroupName" : aws_cloudwatch_log_group.default.name,
      "cloudWatchEncryptionEnabled" : true,
      "idleSessionTimeout" : "20",
      "cloudWatchStreamingEnabled" : true,
      "kmsKeyId" : aws_kms_key.default.arn,
      "runAsEnabled" : true,
      "runAsDefaultUser" : "ec2-user",
      "shellProfile" : {
        "windows" : "",
        "linux" : "cd $${HOME}\nexec /bin/bash"
      }
    }
  }
}

resource "aws_ssm_document" "ssm-permissions" {
  content       = jsonencode(local.ssmrunshell)
  document_type = "Session"
  name          = "SSM-SessionManagerRunShell"
}
