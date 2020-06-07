module "es" {
  source = "../."
  domain_name = "test-7"
  es_version = 7.4
  management_public_ip_addresses = [
    "66.17.11.64/29", ###anskirsh IPs###
    "69.13.16.0/22",  ###random ip###
    "198.02.20.8/21", ###IPs###
    "32.29.195.5",    ###test-EIP###
    "54.19.25.1",   ###test-EIP###
    "52.28.81.8"     ###test-EIP###
  ]
  instance_count = 3
  instance_type = "m5.2xlarge.elasticsearch"
  dedicated_master_threshold = 3
  dedicated_master_type = "m5.xlarge.elasticsearch"
  es_zone_awareness = true
  snapshot_start_hour = 0
  es_zone_awareness_config = 3
  ebs_volume_type = "gp2"   ##Storage type of EBS volumes##
  ebs_volume_size = 512
  advanced_options = {
    "rest.action.multi.allow_explicit_index" = "true"
  }
  tags = {
    team = "anskrish"
    environment = "test"
    service = "elasticsearch"
    version = "v2"
    Terraform = "true"
    CostCenter ="6"
    DeleteMe = "0000-00-00"
    Initiator = "Terraform"
    Owner = "Krishna Rudraraju"
  }
}

module "es-curator" {
  source = "../../terraform-aws-elasticsearch-curator-manage/."

  # AWS Lambda role arn for running curator funtion
  description = "curator lambda to reduce ES cluster log retention"

  # Provide the name of the Lambda function
  function_name = "manage-elasticsearch-log-retention-test"
  role_arn = data.aws_iam_role.role_arn.arn
  handler_name = "handler.handler"
  memory_size = "1200"
  runtime = "python3.6"
  timeout = "300"
  cron = "cron(00 18 * * ? *)"
  lambda_zip_path = "./lambda-v1.0.zip"
  env = "test-es"
  cluster_name = module.es.domain_name
  endpoint = "https://${module.es.endpoint}"
  region = "us-west-2"
  days = "7"
  index_prefix = "logstash-"
tags = {
    team = "anskrish"
    environment = "test"
    service = "elasticsearch-curator-lambda"
    DeleteMe = "0000-00-00"
    Initiator = "Terraform"
    Owner = "Krishna.rudraraju"
  }
}
