resource "aws_iam_role" "create_dlm_lifecycle_assume_role" {
  count = var.role_name != null ? 1 : 0

  name               = "${var.role_name}-assume-role"
  assume_role_policy = jsonencode(var.dlm_lifecycle_assume_role_policy)
}

resource "aws_iam_role_policy" "create_dlm_snapshot_lifecycle_role" {
  count = var.role_name != null ? 1 : 0

  name = "${var.role_name}-lifecycle-role"
  role = aws_iam_role.create_dlm_lifecycle_assume_role[0].id

  policy = jsonencode(var.dlm_snapshot_lifecycle_policy == null ? {
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
        "Resource" : "arn:aws:ec2:${var.aws_account}::snapshot/*"
      }
    ]
  } : var.dlm_snapshot_lifecycle_policy)
}

resource "aws_dlm_lifecycle_policy" "create_dlm_schedules_lifecycle" {
  count = length(var.snapshots_lifecycle)

  description        = var.snapshots_lifecycle[count.index].description != null ? var.snapshots_lifecycle[count.index].description : "Snapshot life cycle ${var.snapshots_lifecycle[count.index].name}"
  execution_role_arn = try(aws_iam_role.create_dlm_lifecycle_assume_role[0].arn, var.assume_role_arn)
  state              = var.snapshots_lifecycle[count.index].state

  policy_details {
    resource_types = var.snapshots_lifecycle[count.index].resource_types
    target_tags    = var.snapshots_lifecycle[count.index].target_tags
    policy_type    = var.snapshots_lifecycle[count.index].policy_type

    schedule {
      name = var.snapshots_lifecycle[count.index].name
      tags_to_add = merge(
        { snapshot-creator = "DLM" },
        var.snapshots_lifecycle[count.index].tags,
        var.snapshots_lifecycle[count.index].copy_tags ? {} : { Name = "${var.snapshots_lifecycle[count.index].name}-each-${var.snapshots_lifecycle[count.index].interval}-${lower(var.snapshots_lifecycle[count.index].interval_unit)}-keep${var.snapshots_lifecycle[count.index].retention_time}-days" }
      )

      create_rule {
        interval      = var.snapshots_lifecycle[count.index].interval
        interval_unit = var.snapshots_lifecycle[count.index].interval_unit
        times         = [var.snapshots_lifecycle[count.index].times]
      }

      retain_rule {
        count = var.snapshots_lifecycle[count.index].retention_time
      }

      copy_tags = var.snapshots_lifecycle[count.index].copy_tags
    }
  }

  tags = merge({ Name = var.snapshots_lifecycle[count.index].name }, var.snapshots_lifecycle[count.index].tags)
}
