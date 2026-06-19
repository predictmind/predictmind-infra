output "alb_dns_name" {
  description = "Public ALB DNS name"
  value       = aws_lb.public.dns_name
}

output "ecr_repository_urls" {
  description = "ECR repository URLs per service"
  value       = { for k, v in aws_ecr_repository.service : k => v.repository_url }
}

output "db_endpoint" {
  description = "RDS PostgreSQL endpoint"
  value       = module.db.db_instance_endpoint
  sensitive   = true
}

output "redis_endpoint" {
  description = "ElastiCache Redis endpoint"
  value       = aws_elasticache_cluster.redis.cache_nodes[0].address
}

output "artifacts_bucket" {
  description = "S3 bucket for artifacts"
  value       = aws_s3_bucket.artifacts.bucket
}
