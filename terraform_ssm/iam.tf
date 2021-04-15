## Export an IAM policy we can use in other projects.

data "aws_iam_policy_document" "ssm_decrypt_policy" {
  statement {
    sid       = "AllowKMSDecrypt"
    effect    = "Allow"
    actions   = ["kms:Decrypt"]
    resources = [aws_kms_key.default.arn]
  }
}

resource "aws_iam_policy" "ssm_decrypt_policy" {
  name        = "SSMDecrypt"
  path        = "/"
  description = "Enable Decrypt so SSM Sessions can work"
  policy      = data.aws_iam_policy_document.ssm_decrypt_policy.json
}

// In addition to the policy we create here, instances that want SSM Session Manger to work
// will likely need these policies attached to them as well:
//
//  resource "aws_iam_role_policy_attachment" "ec2_instance_ssm" {
//    policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
//    role       = aws_iam_role.ROLE_NAME.id
//  }
//
//  resource "aws_iam_role_policy_attachment" "ec2_instance_cloudwatch" {
//    policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
//    role       = aws_iam_role.ROLE_NAME.id
//  }
