# Elastic search Cluster Deployment

Terraform module for deploying and managing Amazon Elasticsearch Service and manage the ES cluster indices log retention using curator function.

This module has two options for creating an Elasticsearch domain:

1. Create an Elasticsearch domain with a public endpoint. Access policy is then based on the intersection of the following two criteria

- source IP address
- client IAM role


2. Create an Elasticsearch domain and join it to a VPC. Access policy is then based on the intersection of the following two criteria:

- security groups applied to Elasticsearch domain
- client IAM role

If vpc_options option is set, Elasticsearch domain is created within a VPC. If not, Elasticsearch domain is created with a public endpoint

NOTE: You can either launch your domain within a VPC or use a public endpoint, but you can't do both. Considering this, adding or removing vpc_options will force DESTRUCTION of the old Elasticsearch domain and CREATION of a new one. 

**If you want Create Elasticsearch domain with public endpoint here is the example way of defination:**

```
module "es" {
  source = "../."
  domain_name = "test-7"
  es_version = 7.4

  management_public_ip_addresses = [
    "10.20.0.0/24",    ###test-vpc###
    "54.19.25.12",   ###bastion-EIP###
    "54.28.11.9"     ###anskrish-EIP###
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
}
```

**If you want to create  Elasticsearch domain in a VPC with dedicated master nodes here is the example way of defination:**

```
module "es" {
  source = "../."
  domain_name = "test-7"
  es_version = 7.4

  vpc_options = {
    security_group_ids = ["sg-XXXXXXXX"]
    subnet_ids = ["subnet-YYYYYYYY","subnet-YYYYYYYY"]   ###make sure to use two or more subnets if you enabled zone_awareness true.
  }

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
}
```

Several options affect the resilience and scalability of your Elasticsearch domain.

For a production deployment: 

- set instance_count to an even number (default: 6) greater than or equal to the dedicated_master_threshold (default: 10)
- choose an instance_type that is not in the T2 family
- set es_zone_awareness to true.

This will result in a cluster with three dedicated master nodes, balanced across two availability zones.

For a production deployment it may also make sense to use EBS volumes rather that instance storage; to do so, set ebs_volume_size greater than 0 and optionally specify a value for ebs_volume_type (right now the only supported values are gp2 and magnetic).

**Dependency:**

1. Requires terraform 0.12.20
2. Assumed role to switch respective AWS environment
3. management_public_ip_addresses list to allow cluster access.
4. zip file for Lambda function curator job.
5. IAM role for Lambda function


| Name | Description | Type | Default | Required
| ------ | ------ | ------ | ------ | ------ |
| advanced_options | Map of key-value string pairs to specify advanced configuration options. Note that the values for these configuration options must be strings (wrapped in quotes) or they may be wrong and cause a perpetual diff, causing Terraform to want to recreate your Elasticsearch domain on every apply | map(string) | {} | No |
| es_version | Version of Elasticsearch to deploy | String | 7.4 | Yes |
| es_zone_awareness | Enable zone awareness for Elasticsearch cluster | bool | "true" | Yes |
| instance_count | Number of data nodes in the cluster | Number | 3 | Yes |
| management_public_ip_addresses | List of IP addresses from which to permit management traffic (default []).  Note that a client must match both the IP address and the IAM role patterns in order to be permitted access | list(string) | ["10.10.0.0/24", "66.147.11.62/23" ] | Yes |
| vpc_options | A map of supported vpc options | map(list(string)) | security_group_ids = [] subnet_ids = [] | No |
| node_to_node_encryption_enabled | Whether to enable node-to-node encryption | bool | false | No |
| snapshot_start_hour | Hour at which automated snapshots are taken, in UTC (default 0) | Number | 0 | Yes |
| management_iam_roles | List of IAM role ARNs from which to permit management traffic (default ['*']).  Note that a client must match both the IP address and the IAM role patterns in order to be permitted access | list(string) |[ "*" ] | No |
| instance_type | ES instance type for data nodes in the cluster | String | "m5.2xlarge.elasticsearch" | Yes |
| dedicated_master_threshold | The no of instances above which dedicated master nodes will be used | Number | "3" | Yes |
| dedicated_master_type | ES instance type to be used for dedicated masters (default same as instance_type) | String | m4.large.elasticsearch | Yes |
| domain_name | Domain name for Elasticsearch cluster | Stirng | test-7 | Yes |
| use_prefix | Flag indicating whether or not to use the domain_prefix. Default: true | bool | true | No |
| domain_prefix | String to be prefixed to search domain | String | "" | No |
| ebs_volume_size | Optionally use EBS volumes for data storage by specifying volume size in GB (default 0) | Number | 512 | Yes|
| ebs_volume_type |  Storage type of EBS volumes, if used (default gp2) | String | "gp2" | No |
| env | environment name | string | "manage-elasticsearch-log-retention-test" | yes |
| Lambda zip file | Jfrog API Key | export | | Yes |
| function_name | Lambda function name | Sting | "" | Yes |
| cron | cron schedule time to trigger an event for curator lambda function | string | "cron(00 15 * * ? *)" | Yes |



**Steps to deploy Elasticsearch domain with public endpoint along with Curator Lambda function deployment**

**#Step 1**. Clone the  repo and create a folder under respective environment location

**#Step 2**: Copy the "test" folder content to newly created folder(in step 1) and edit the below files.

**1. Update main.tf as instructed in below**

1.1 Configure the backend bucket in main.tf

```
terraform {
  required_version = "= 0.12.20"
  backend "s3" {
    bucket = "test-terraform-services"
    region = "us-west-2"
  }
}
```
1.2 Update the IAM role name.

Note: Follow READme instructions for [IAM role creation]

Example:

```
data "aws_iam_role" "role_arn" {
  name = "${function_name}-${env}"
}
```
**2. Update the elastisearch-cluster.tf for below variable values based on your requirement.**

###update the below variable values ###

- domain_name -- Update the ES cluster domain  name(cluster name).
- es_version  -- Update the ES cluster version name which you want to deploy
- management_public_ip_addresses  -- Update the all allowed IP'd details
- instance_count -- Update the number of instances in the cluster.
- instance_type -- Update the type of instance which you want to create while deploying ES cluster.
- dedicated_master_threshold -- Update the number of dedicated master nodes count.
- dedicated_master_type -- Update the dedicated master nodes type.
- es_zone_awareness -- If you want to deploy multi AZ, you have to choose "true" option. 
- snapshot_start_hour -- Snapshot time( default time is 00.00 UTC)
- es_zone_awareness_config -- If you choose Multi Az true, you have to choose how many zones your cluster will deploy (2 or 3 ). 
- ebs_volume_size -- Update the Size of Volume.
- function_name -- Update the Curator Lambda function name with stack name
ex: function_name = "manage-elasticsearch-log-retention-{env}"
- index_prefix - ES indices prefix (ex: "logstash-")
- days -- Retention days
- lambda_zip_path -- Update the local zip file path(ex: ./lambda-${GIT_TAG_BASE_VERSION}.${REVISION}.zip)
- env -- Update the respective environment name with "es" extention (Example: stage-es)
- cron  = "cron(MIN HOUR DOM, MON, DOW, YEAR)"

``` - MIN      Minute field    0 to 59
- HOUR     Hour field      0 to 23      
- DOM      Day of Month    1-31
- MON      Month field     1-12
- DOW      Day Of Week     0-6
- YEAR     Year field
- "*"      The "*" means all the possible unit
```

Provide the tags:

```
team : Team Name 

environment: Test, Production, QA, Stage etc. 

service: Service Name 

version: v2

CostCenter: 6

DeleteMe:  0000-00-00

Initiator: Terraform

Owner:  Krishna Rudraraju

```

3. Genarate and Export the JFROG_ARTIFACTORY_API_KEY 

```
export JFROG_ARTIFACTORY_API_KEY=xxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

**Example: Sample Makefile**

```
TERRAFORM=terraform
USER=$(shell id -un)
ARTIFACTORY_BASE_URL=https://xxxx.jfrog.io/xxxxx/infra-lambda/curator-lambda-es
GIT_TAG_BASE_VERSION=v1
REVISION=0
env=

all: pull-curator-lambda-es set plan

pull-curator-lambda-es:
	curl -s -L -H "X-JFrog-Art-Api:${JFROG_ARTIFACTORY_API_KEY}" -O ${ARTIFACTORY_BASE_URL}/${GIT_TAG_BASE_VERSION}.${REVISION}/lambda-${GIT_TAG_BASE_VERSION}.${REVISION}.zip

set:
		rm -f .terraform/terraform.tfstate
		terraform init --backend-config="key=unit/{account-number}/${env}-es-cluster/terraform.tfstate"

plan:
    terraform plan -out=${env}.out

apply:
    terraform apply "${env}.out"
    
clean:
    rm -f *.tfvars
    rm -f *.out
 ```
**#Step 3**: Execute the below steps.

Note: Assume the required account role and execute below steps.

- make all
- make apply

