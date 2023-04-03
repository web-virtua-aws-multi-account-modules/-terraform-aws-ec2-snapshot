# AWS DLM snapshots life cycle for multiples accounts and regions with Terraform module
* This module simplifies creating and configuring of a DLM snapshots life cycle across multiple accounts and regions on AWS

* Is possible use this module with one region using the standard profile or multi account and regions using multiple profiles setting in the modules.

## Actions necessary to use this module:

* Create file versions.tf with the exemple code below:
```hcl
terraform {
  required_version = ">= 1.1.3"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.9"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 2.0"
    }
  }
}
```

* Criate file provider.tf with the exemple code below:
```hcl
provider "aws" {
  alias   = "alias_profile_a"
  region  = "us-east-1"
  profile = "my-profile"
}

provider "aws" {
  alias   = "alias_profile_b"
  region  = "us-east-2"
  profile = "my-profile"
}
```


## Features enable of VPC configurations for this module:

- DLM schedules lifecycle
- IAM role
- IAM role policy

## Usage exemples

### Create snapshot lifecycle making one each 24hs and each hour

```hcl
module "disk_snapshot" {
  source = "web-virtua-aws-multi-account-modules/ec2-snapshot/aws"

  role_name = "tf-snapshot-lifecycle"

  snapshots_lifecycle = [
    {
      name           = "tf-snapshot-lifecycle-test-1"
      description    = "Snapshot test"
      retention_time = 7
      times          = "00:01"
      interval       = 24

      target_tags = {
        Name = "tf-test-api"
      }
    },
    {
      name           = "tf-snapshot-lifecycle-test-2"
      description    = "Snapshot test"
      retention_time = 7
      times          = "11:00"
      interval       = 1

      target_tags = {
        Name = "tf-test-api"
      }
    }
  ]

  providers = {
    aws = aws.alias_profile_b
  }
}
```

## Variables

| Name | Type | Default | Required | Description | Options |
|------|-------------|------|---------|:--------:|:--------|
| assume_role_arn | `string` | `null` | no | If defined will not be created a new assume role, else will be used this role ARN, for use a ARN existing not must be defined role_name variable | `-` |
| aws_account | `string` | `*` | no | If defined the permissions will be to this accont, else for any | `-` |
| role_name | `string` | `null` | no | If defined will be create a new role with this name | `-` |
| snapshots_lifecycle | `list(object)` | `-` | yes | List with snapshots lifecycle, resource_types variable can be VOLUME or INSTANCE, policy_type variable can be EBS_SNAPSHOT_MANAGEMENT, IMAGE_MANAGEMENT or EVENT_BASED_POLICY and state varible can be ENABLED or DESABLED | `-` |
| dlm_lifecycle_assume_role_policy | `any` | `object` | no | Policy to DLM  assume role | `-` |
| dlm_snapshot_lifecycle_policy | `any` | `object` | no | Policy to DLM life cycle | `-` |

* Model of variable snapshots_lifecycle
```hcl
variable "snapshots_lifecycle" {
  description = "List with snapshots lifecycle, resource_types variable can be VOLUME or INSTANCE, policy_type variable can be EBS_SNAPSHOT_MANAGEMENT, IMAGE_MANAGEMENT or EVENT_BASED_POLICY and state varible can be ENABLED or DESABLED"
  type = list(object({
    name           = string
    target_tags    = any
    description    = optional(string)
    state          = optional(string, "ENABLED")
    resource_types = optional(list(string), ["VOLUME"])
    interval       = optional(number, 24)
    interval_unit  = optional(string, "HOURS")
    times          = optional(string, "00:01")
    retention_time = optional(number, 7)
    copy_tags      = optional(bool, false)
    policy_type    = optional(string, "EBS_SNAPSHOT_MANAGEMENT")
    tags           = optional(any, {})
  }))
  default = [
    {
      name           = "tf-snapshot-lifecycle-test-1"
      description    = "Snapshot test"
      retention_time = 7
      times          = "14:45"
      interval       = 1

      target_tags = {
        Name = "tf-test-api"
      }
    }
  ]
}
```

* Default value of variable dlm_lifecycle_assume_role_policy
```hcl
variable "dlm_lifecycle_assume_role_policy" {
  description = "Policy to DLM  assume role"
  type        = any
  default = {
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : "sts:AssumeRole",
        "Principal" : {
          "Service" : "dlm.amazonaws.com"
        },
        "Effect" : "Allow",
        "Sid" : ""
      }
    ]
  }
}
```

* Default value of variable dlm_snapshot_lifecycle_policy
```hcl
variable "dlm_snapshot_lifecycle_policy" {
  description = "Policy to DLM life cycle"
  type        = any
  default = {
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "ec2:CreateSnapshot",
          "ec2:CreateSnapshots",
          "ec2:DeleteSnapshot",
          "ec2:DescribeInstances",
          "ec2:DescribeVolumes",
          "ec2:DescribeSnapshots"
        ],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "ec2:CreateTags"
        ],
        "Resource" : "arn:aws:ec2:*::snapshot/*"
      }
    ]
  }
}
```

## Resources

| Name | Type |
|------|------|
| [aws_iam_role.create_dlm_lifecycle_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.create_dlm_snapshot_lifecycle_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_dlm_lifecycle_policy.create_dlm_schedules_lifecycle](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dlm_lifecycle_policy) | resource |

## Outputs

| Name | Description |
|------|-------------|
| `schedules_lifecycle` | DLM schedules lifecycle |
| `lifecycle_assume_role` | DLM lifecycle assume role |
| `snapshot_lifecycle_role` | DLM snapshot lifecycle role |
