data "aws_iam_policy_document" "es_management_access" {
  count = false == local.inside_vpc ? 1 : 0

  statement {
    actions = [
      "es:*",
    ]

    resources = [
      "${aws_elasticsearch_domain.es[0].arn}/*",
    ]

    principals {
      type = "AWS"

      identifiers = distinct(compact(var.management_iam_roles))
    }

    condition {
      test = "IpAddress"
      variable = "aws:SourceIp"

      values = distinct(compact(var.management_public_ip_addresses))
    }
  }
}



resource "aws_elasticsearch_domain" "es" {
  count = false == local.inside_vpc ? 1 : 0

  domain_name = local.domain_name
  elasticsearch_version = var.es_version

  cluster_config {
    instance_type = var.instance_type
    instance_count = var.instance_count
    dedicated_master_enabled = var.instance_count >= var.dedicated_master_threshold ? true : false
    dedicated_master_count = var.instance_count >= var.dedicated_master_threshold ? 3 : 0
    dedicated_master_type = var.instance_count >= var.dedicated_master_threshold ? (var.dedicated_master_type != "false" ? var.dedicated_master_type : var.instance_type) : ""
    zone_awareness_enabled = var.es_zone_awareness
    zone_awareness_config {
      availability_zone_count = var.es_zone_awareness_config
   }
  }

  ebs_options {
    ebs_enabled = var.ebs_volume_size > 0 ? true : false
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
  }

  node_to_node_encryption {
    enabled = var.node_to_node_encryption_enabled
  }

  snapshot_options {
    automated_snapshot_start_hour = var.snapshot_start_hour
  }

  advanced_options = var.advanced_options

  tags = var.tags
}

resource "aws_elasticsearch_domain_policy" "es_management_access" {
  count = false == local.inside_vpc ? 1 : 0

  domain_name = local.domain_name
  access_policies = data.aws_iam_policy_document.es_management_access[0].json
}
