# --- PostgreSQL (RDS) ---
# Note: TimescaleDB is available via the timescaledb extension; for managed
# time-series at scale consider Timescale Cloud and point the services at it.
module "db" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 7.2"

  identifier = "${local.name}-pg"

  engine               = "postgres"
  engine_version       = "17"
  family               = "postgres17"
  instance_class       = var.db_instance_class
  allocated_storage    = 50
  max_allocated_storage = 200

  db_name  = "predictmind"
  username = var.db_username
  password = var.db_password
  port     = 5432

  multi_az               = var.environment == "production"
  db_subnet_group_name   = module.vpc.database_subnet_group_name
  vpc_security_group_ids = [aws_security_group.db.id]

  backup_retention_period = 30
  deletion_protection     = var.environment == "production"
  storage_encrypted       = true
}

resource "aws_security_group" "db" {
  name_prefix = "${local.name}-db-"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "Postgres from within VPC"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }
}

# --- Redis (ElastiCache) ---
resource "aws_elasticache_subnet_group" "redis" {
  name       = "${local.name}-redis"
  subnet_ids = module.vpc.private_subnets
}

resource "aws_elasticache_cluster" "redis" {
  cluster_id           = "${local.name}-redis"
  engine               = "redis"
  node_type            = var.redis_node_type
  num_cache_nodes      = 1
  parameter_group_name = "default.redis7"
  port                 = 6379
  subnet_group_name    = aws_elasticache_subnet_group.redis.name
  security_group_ids   = [aws_security_group.redis.id]
}

resource "aws_security_group" "redis" {
  name_prefix = "${local.name}-redis-"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "Redis from within VPC"
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }
}

# --- Object storage (S3) for reports, exports, backtest artifacts ---
resource "aws_s3_bucket" "artifacts" {
  bucket = "${local.name}-artifacts"
}

resource "aws_s3_bucket_public_access_block" "artifacts" {
  bucket                  = aws_s3_bucket.artifacts.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id
  versioning_configuration {
    status = "Enabled"
  }
}
