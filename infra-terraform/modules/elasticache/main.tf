locals {
  common_tags = merge(var.tags, {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  })
}

################################################################################
# Subnet Group
################################################################################

resource "aws_elasticache_subnet_group" "this" {
  count = var.enable_redis ? 1 : 0

  name       = "${var.project_name}-${var.environment}-redis-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-redis-subnet-group"
  })
}

################################################################################
# ElastiCache Redis Cluster
################################################################################

resource "aws_elasticache_cluster" "this" {
  count = var.enable_redis ? 1 : 0

  cluster_id           = "${var.project_name}-${var.environment}-redis"
  engine               = "redis"
  engine_version       = var.engine_version
  node_type            = var.node_type
  num_cache_nodes      = 1
  parameter_group_name = "default.redis7"
  port                 = 6379

  subnet_group_name  = aws_elasticache_subnet_group.this[0].name
  security_group_ids = [var.security_group_id]

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-redis"
  })
}
