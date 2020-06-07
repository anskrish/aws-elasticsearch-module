variable "domain_name" {
  description = "Domain name for Elasticsearch cluster"
  default = "es-domain"
}

variable "es_version" {
  description = "Version of Elasticsearch to deploy (default 6.4)"
  default = "6.7"
}

variable "instance_type" {
  description = "ES instance type for data nodes in the cluster (default t2.small.elasticsearch)"
  default = "m4.large.elasticsearch"
}

variable "instance_count" {
  description = "Number of data nodes in the cluster (default 2)"
  default = 2
}

variable "dedicated_master_type" {
  description = "ES instance type to be used for dedicated masters (default same as instance_type)"
  default = "m4.large.elasticsearch"
}

variable "dedicated_master_threshold" {
  description = "The number of instances above which dedicated master nodes will be used. Default: 3"
  default = 3 
}

variable "es_zone_awareness" {
  description = "Enable zone awareness for Elasticsearch cluster (default false)"
  default = "false"
}

variable "es_zone_awareness_config" {
  description = "Enable Multi Az"
  default = "3"
}

variable "ebs_volume_size" {
  description = "Optionally use EBS volumes for data storage by specifying volume size in GB (default 0)"
  default = 0
}

variable "ebs_volume_type" {
  description = "Storage type of EBS volumes, if used (default gp2)"
  default = "gp2"
}

variable "node_to_node_encryption_enabled" {
  description = "Whether to enable node-to-node encryption."
  default = false
}

variable "snapshot_start_hour" {
  description = "Hour at which automated snapshots are taken, in UTC (default 0)"
  default = 0
}

variable "advanced_options" {
  description = "Map of key-value string pairs to specify advanced configuration options. Note that the values for these configuration options must be strings (wrapped in quotes) or they may be wrong and cause a perpetual diff, causing Terraform to want to recreate your Elasticsearch domain on every apply."
  default = {}
}

variable "tags" {
  description = "tags to apply to all resources"
  type = map
  default = {}
}

variable "use_prefix" {
  description = "Flag indicating whether or not to use the domain_prefix. Default: true"
  default = true
}

variable "domain_prefix" {
  description = "String to be prefixed to search domain. Default: tf-"
  default = ""
}


variable "management_iam_roles" {
  description = "List of IAM role ARNs from which to permit management traffic (default ['*']).  Note that a client must match both the IP address and the IAM role patterns in order to be permitted access."
  type = list
  default = ["*"]
}


variable "management_public_ip_addresses" {
  description = "List of IP addresses from which to permit management traffic (default []).  Note that a client must match both the IP address and the IAM role patterns in order to be permitted access."
  type = list
  default = []
}

variable "vpc_options" {
  description = "A map of supported vpc options"
  type = map

  default = {
    security_group_ids = []
    subnet_ids = []
  }
}

variable "create_iam_service_linked_role" {
  description = "Whether to create IAM service linked role for AWS ElasticSearch service. Can be only one per AWS account."
  type        = bool
  default     = true
}
