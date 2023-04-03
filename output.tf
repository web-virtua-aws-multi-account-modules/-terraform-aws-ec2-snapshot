output "schedules_lifecycle" {
  description = "DLM schedules lifecycle"
  value       = aws_dlm_lifecycle_policy.create_dlm_schedules_lifecycle
}

output "lifecycle_assume_role" {
  description = "DLM lifecycle assume role"
  value       = try(aws_iam_role.create_dlm_lifecycle_assume_role[0], var.assume_role_arn)
}

output "snapshot_lifecycle_role" {
  description = "DLM snapshot lifecycle role"
  value       = try(aws_iam_role_policy.create_dlm_snapshot_lifecycle_role[0], null)
}
