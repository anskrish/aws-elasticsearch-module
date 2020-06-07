resource "aws_iam_role" "manage_curator_role" {
  name = "${var.function_name}-${var.env}"
  description = "Manage ES curator cluster role for Lambda function"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}
resource "aws_iam_policy" "policy" {
  name        = "manage-curator-policy"
  description = "Manage ES curator cluster role for Lambda function"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
      {
          "Action": [
              "logs:CreateLogStream"
          ],
          "Resource": [
              "arn:aws:logs:${var.region}:${var.account_number}:log-group:/aws/lambda/curator-elasticsearch-${var.env}-live*:*"
          ],
          "Effect": "Allow"
      },
      {
          "Action": [
              "logs:PutLogEvents"
          ],
          "Resource": [
              "arn:aws:logs:${var.region}:${var.account_number}:log-group:/aws/lambda/curator-elasticsearch-${var.env}-live*:*:*"
          ],
          "Effect": "Allow"
      },
      {
          "Action": [
              "es:ESHttpDelete",
              "es:ESHttpGet",
              "es:ESHttpHead",
              "es:ESHttpPost",
              "es:ESHttpPut"
          ],
          "Resource": [
              "arn:aws:es:${var.region}:${var.account_number}:domain/${var.cluster_name1}/*"
          ],
          "Effect": "Allow"
      }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "policy-attach" {
  role       = aws_iam_role.manage_curator_role.name
  policy_arn = aws_iam_policy.policy.arn
}
