variable "aws_account" {
  description = "If defined the permissions will be to this accont, else for any"
  type        = string
  default     = "*"
}

variable "assume_role_arn" {
  description = "If defined will not be created a new assume role, else will be used this role ARN, for use a ARN existing not must be defined role_name variable"
  type        = string
  default     = null
}

variable "role_name" {
  description = "If defined will be create a new role with this name"
  type        = string
  default     = null
}

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
}

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

variable "dlm_snapshot_lifecycle_policy" {
  description = "Policy to DLM life cycle"
  type        = any
  default     = null
}
