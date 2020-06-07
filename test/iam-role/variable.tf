variable "function_name" {
  description = "A unique name for your Lambda Function"
  default = "manage-elasticsearch-log-retention"
}
variable "account_number" {
  default = "217247731217"
}
variable "env" {
  default = "test-es"
}
variable "region" {
  description = "AWS region"
  default = "us-west-2"
}
variable "cluster_name1" {
  description = "Cluster name"
  default = "test-7"
}
