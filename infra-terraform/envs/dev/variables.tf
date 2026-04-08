variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-northeast-2"
}

variable "aws_profile" {
  description = "AWS CLI profile name"
  type        = string
  default     = "default"
}

variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "enable_nat_gateway" {
  description = "Enable managed NAT Gateway (recommended for prod)"
  type        = bool
  default     = false
}

variable "enable_nat_instance" {
  description = "Enable NAT Instance t3.micro (cost-saving for dev)"
  type        = bool
  default     = true
}

variable "enable_bastion" {
  description = "Enable Bastion Host security group"
  type        = bool
  default     = false
}

variable "bastion_allowed_cidrs" {
  description = "CIDR blocks allowed to SSH into Bastion"
  type        = list(string)
  default     = []
}

variable "db_engine" {
  description = "Database engine (mysql or postgres)"
  type        = string
  default     = "postgres"
}

variable "db_engine_version" {
  description = "Database engine version"
  type        = string
  default     = ""
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "db_name" {
  description = "Database name"
  type        = string
}

variable "db_username" {
  description = "Database master username"
  type        = string
  default     = "dbadmin"
  sensitive   = true
}

variable "db_backup_retention_period" {
  description = "Number of days to retain RDS backups"
  type        = number
  default     = 1
}

variable "multi_az" {
  description = "Enable Multi-AZ for RDS"
  type        = bool
  default     = false
}

variable "deletion_protection" {
  description = "Enable deletion protection for RDS"
  type        = bool
  default     = false
}

variable "enable_https" {
  description = "Enable HTTPS on ALB"
  type        = bool
  default     = false
}

variable "acm_certificate_arn" {
  description = "ACM certificate ARN for HTTPS"
  type        = string
  default     = ""
}

variable "ecr_repo_names" {
  description = "List of ECR repository names"
  type        = list(string)
  default     = ["api"]
}

variable "ecs_services" {
  description = "Map of ECS services configuration"
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

variable "enable_redis" {
  description = "Enable ElastiCache Redis"
  type        = bool
  default     = true
}

variable "redis_node_type" {
  description = "ElastiCache Redis node type"
  type        = string
  default     = "cache.t3.micro"
}
