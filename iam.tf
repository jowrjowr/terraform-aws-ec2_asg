
# every ec2 instance requires this as a basic minimum to make use of any
# sort of non-trivial instance role.

data "aws_iam_policy_document" "ec2_instance_assumerole" {

  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
    effect = "Allow"
  }
}

resource "aws_iam_role" "ec2_instance" {

  path               = "/"
  name               = "${var.name}_${var.environment}"
  description        = "manages ${var.name} EC2 instance access"
  assume_role_policy = data.aws_iam_policy_document.ec2_instance_assumerole.json
  tags = {
    Name      = "${var.name} instance role"
    terraform = "true"
    project   = "teleport"
  }
}

resource "aws_iam_instance_profile" "ec2_instance" {
  name = "${var.name}_${var.environment}_instance_profile"
  role = aws_iam_role.ec2_instance.name
}

# add credstash policy

data "aws_iam_policy_document" "standard_policies" {

  version = "2012-10-17"

  statement {
    sid = "AllowTagRead"
    actions = [
      "ec2:DescribeInstances",
      "ec2:describetags"
    ]
    resources = [
      "*"
    ]
    effect = "Allow"
  }

  statement {
    sid = "AllowCredstashKMS"
    actions = [
      "kms:Decrypt"
    ]
    resources = [
      aws_kms_key.credstash.arn
    ]
    effect = "Allow"
  }

  statement {
    sid = "AllowCredstashDynamoDB"
    actions = [
      "dynamodb:GetItem",
      "dynamodb:Query",
      "dynamodb:Scan"
    ]
    resources = [
      aws_dynamodb_table.credstash.arn
    ]
    effect = "Allow"
  }

  statement {
    sid = "IAMRDS"
    actions = [
      "rds-db:connect"
    ]
    resources = [
      "arn:aws:rds-db:eu-west-1:${var.account_id}:dbuser:*/${var.db_username}"
    ]
    effect = "Allow"
  }
}

resource "aws_iam_policy" "standard_policy" {

  name   = "${var.name}_${var.environment}_credstash"
  path   = "/"
  policy = data.aws_iam_policy_document.standard_policies.json
}

resource "aws_iam_role_policy_attachment" "credstash" {
  role       = aws_iam_role.ec2_instance.name
  policy_arn = aws_iam_policy.standard_policy.arn
}

# we want to take a list of json strings for additional policies we want to
# attach to the instance's role, without being a shitshow to manage.

resource "aws_iam_policy" "additional_policies" {
  for_each = var.ec2_policies
  name     = "${var.name}_${var.environment}_${each.key}"
  path     = "/"
  policy   = each.value
}

resource "aws_iam_role_policy_attachment" "additional_attachments" {
  for_each   = var.ec2_policies
  role       = aws_iam_role.ec2_instance.name
  policy_arn = aws_iam_policy.additional_policies[each.key].arn
}
