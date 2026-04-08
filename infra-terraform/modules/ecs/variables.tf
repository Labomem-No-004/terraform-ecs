variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for ECS tasks"
  type        = list(string)
}

variable "ecs_security_group_id" {
  description = "Security group ID for ECS tasks"
  type        = string
}

variable "alb_listener_arn" {
  description = "ARN of the ALB listener to attach target groups"
  type        = string
}

variable "ecs_services" {
  description = "Map of ECS services to create"
  type = map(object({
    cpu               = optional(number, 256)
    memory            = optional(number, 512)
    port              = optional(number, 8080)
    desired_count     = optional(number, 1)
    health_check_path = optional(string, "/health")
    image             = optional(string, "")
    environment_vars  = optional(map(string), {})
    min_capacity      = optional(number, 1)
    max_capacity      = optional(number, 4)
    cpu_threshold     = optional(number, 70)
  }))
  default = {}
}

variable "tags" {
  description = "Additional tags for all resources"
  type        = map(string)
  default     = {}
}
