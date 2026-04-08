locals {
  common_tags = merge(var.tags, {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  })

  engine_version = var.db_engine_version != "" ? var.db_engine_version : (
    var.db_engine == "postgres" ? "15" : "8.0"
  )

  port = var.db_engine == "postgres" ? 5432 : 3306
}

################################################################################
# DB Subnet Group
################################################################################

resource "aws_db_subnet_group" "this" {
  name       = "${var.project_name}-${var.environment}-db-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-db-subnet-group"
  })
}

################################################################################
# Random Password
################################################################################

resource "random_password" "master" {
  length           = 20
  special          = true
  override_special = "!#$%^&*()-_=+[]{}|:,.<>?"
}

################################################################################
# Secrets Manager
################################################################################

resource "aws_secretsmanager_secret" "db_password" {
  name        = "${var.project_name}/${var.environment}/rds/master-password"
  description = "RDS master password for ${var.project_name}-${var.environment}"

  tags = local.common_tags
}

resource "aws_secretsmanager_secret_version" "db_password" {
  secret_id = aws_secretsmanager_secret.db_password.id
  secret_string = jsonencode({
    username = var.db_username
    password = random_password.master.result
    engine   = var.db_engine
    host     = aws_db_instance.this.address
    port     = local.port
    dbname   = var.db_name
  })
}

################################################################################
# RDS Instance
################################################################################

resource "aws_db_instance" "this" {
  identifier = "${var.project_name}-${var.environment}-db"

  engine         = var.db_engine
  engine_version = local.engine_version
  instance_class = var.db_instance_class

  allocated_storage     = var.db_allocated_storage
  max_allocated_storage = var.db_max_allocated_storage
  storage_type          = "gp3"

  db_name  = var.db_name
  username = var.db_username
  password = random_password.master.result

  multi_az            = var.multi_az
  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [var.security_group_id]

  backup_retention_period = var.backup_retention_period
  backup_window           = var.backup_window
  maintenance_window      = var.maintenance_window

  deletion_protection       = var.deletion_protection
  skip_final_snapshot       = var.environment == "dev" ? true : false
  final_snapshot_identifier = var.environment == "dev" ? null : "${var.project_name}-${var.environment}-db-final-snapshot"

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-db"
  })
}
