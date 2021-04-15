# Service Linked Roles
resource "aws_iam_service_linked_role" "spotfleet" {
  aws_service_name = "spotfleet.amazonaws.com"
}

resource "aws_iam_service_linked_role" "spot" {
  aws_service_name = "spot.amazonaws.com"
  description      = "Default EC2 Spot Service Linked Role"
}

# Application Autoscaling Role
resource "aws_iam_role" "application_autoscaling" {
  name               = "aws-ec2-spot-fleet-autoscale-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "application-autoscaling.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "application_autoscaling" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2SpotFleetAutoscaleRole"
  role       = aws_iam_role.application_autoscaling.id
}

# Spot Fleet Role
resource "aws_iam_role" "spot_fleet_tagging" {
  name               = "aws-ec2-spot-fleet-tagging-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "spotfleet.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "spot_fleet_tagging" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2SpotFleetTaggingRole"
  role       = aws_iam_role.spot_fleet_tagging.id
}
