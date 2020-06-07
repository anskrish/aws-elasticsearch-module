provider "aws" {
  region = var.region
}

terraform {
  required_version = "= 0.12.20"
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
data "aws_iam_role" "role_arn" {
  name = "manage-elasticsearch-log-retention-test-es"
}
