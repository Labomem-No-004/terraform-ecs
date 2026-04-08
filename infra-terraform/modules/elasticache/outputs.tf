output "redis_endpoint" {
  description = "Redis cluster endpoint"
  value       = var.enable_redis ? aws_elasticache_cluster.this[0].cache_nodes[0].address : null
}

output "redis_port" {
  description = "Redis port"
  value       = var.enable_redis ? aws_elasticache_cluster.this[0].cache_nodes[0].port : null
}
