output "cluster_id" {
  description = "ID of the ECS cluster"
  value       = aws_ecs_cluster.this.id
}

output "cluster_name" {
  description = "Name of the ECS cluster"
  value       = aws_ecs_cluster.this.name
}

output "service_names" {
  description = "Map of service keys to ECS service names"
  value       = { for k, v in aws_ecs_service.this : k => v.name }
}

output "task_execution_role_arn" {
  description = "ARN of the ECS task execution role"
  value       = aws_iam_role.task_execution.arn
}

output "task_role_arn" {
  description = "ARN of the ECS task role"
  value       = aws_iam_role.task.arn
}

output "target_group_arns" {
  description = "Map of service keys to target group ARNs"
  value       = { for k, v in aws_lb_target_group.this : k => v.arn }
}
