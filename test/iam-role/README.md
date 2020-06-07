**Description:** 

To Create ES curator Lambda function, we need to create IAM role to execute it. Here are the steps for IAM role creation for ES curator lambda function.

**Dependency:**

1. Requires terraform 0.12.20
2. Respective AWS account number
3. ES cluster name

**Steps for Deployment**

1. **1. Update main.tf as instructed in below**

```
terraform {
  required_version = "= 0.12.20"
  backend "s3" {
    bucket = "terraform-terst"
    region = "us-west-2"
  }
}
```

2. Update the variable.tf file

* function_name -  Lambda function name (We are creating IAM role based on Lambda function name)
* account_number - Respective AWS account number
* env - respective environment name.  
example: 
   - stage-es
   - nightly-es   etc..
* cluster_name1 - Mention the respective environment ES cluster name.

Note: If you already created IAM role earlier for one ES cluster but you want to use same IAM role for another ES cluster, then you need to add another variable as like "cluster_name1". and add resource arn in iam.tf file like below. 

For example: If you add another variable for another cluster is cluster_name2, then you have to define arn like below in iam.tf

```
"Resource": [
              "arn:aws:es:${var.region}:${var.account_number}:domain/${var.cluster_name1}/*",
              "arn:aws:es:${var.region}:${var.account_number}:domain/${var.cluster_name2}/*"
          ],
```

**Example: Sample Makefile**

```

TERRAFORM=terraform
USER=$(shell id -un)

all: set plan

set :
		rm -f .terraform/terraform.tfstate
		terraform init --backend-config="key=unit/{account-number}/{env}-es-cluster-iam-role/terraform.tfstate"


plan:
    terraform plan -out=${env}.out

apply:
    terraform apply "${env}.out"

clean:
    rm -f *.tfvars
    rm -f *.out

```

**Execution steps**

Note: Assume the required account role and execute below steps.

* make all
* make apply-iam


