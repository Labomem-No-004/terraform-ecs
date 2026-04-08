terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  }
}

################################################################################
# VPC
################################################################################

module "vpc" {
  source = "../../modules/vpc"

  project_name        = var.project_name
  environment         = var.environment
  vpc_cidr            = var.vpc_cidr
  enable_nat_gateway  = var.enable_nat_gateway
  enable_nat_instance = var.enable_nat_instance
}

################################################################################
# Security Groups
################################################################################

module "security_groups" {
  source = "../../modules/security_groups"

  project_name          = var.project_name
  environment           = var.environment
  vpc_id                = module.vpc.vpc_id
  db_port               = var.db_engine == "mysql" ? 3306 : 5432
  enable_bastion        = var.enable_bastion
  bastion_allowed_cidrs = var.bastion_allowed_cidrs
}

################################################################################
# ALB
################################################################################

module "alb" {
  source = "../../modules/alb"

  project_name      = var.project_name
  environment       = var.environment
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  security_group_id = module.security_groups.alb_sg_id
  enable_https      = var.enable_https
  acm_certificate_arn = var.acm_certificate_arn
}

################################################################################
# ECR
################################################################################

module "ecr" {
  source = "../../modules/ecr"

  project_name   = var.project_name
  environment    = var.environment
  ecr_repo_names = var.ecr_repo_names
}

################################################################################
# ECS
################################################################################

module "ecs" {
  source = "../../modules/ecs"

  project_name          = var.project_name
  environment           = var.environment
  aws_region            = var.aws_region
  vpc_id                = module.vpc.vpc_id
  private_subnet_ids    = module.vpc.private_subnet_ids
  ecs_security_group_id = module.security_groups.ecs_sg_id
  alb_listener_arn      = var.enable_https ? module.alb.https_listener_arn : module.alb.http_listener_arn
  ecs_services          = var.ecs_services
}

################################################################################
# RDS
################################################################################

module "rds" {
  source = "../../modules/rds"

  project_name        = var.project_name
  environment         = var.environment
  vpc_id              = module.vpc.vpc_id
  private_subnet_ids  = module.vpc.private_subnet_ids
  security_group_id   = module.security_groups.rds_sg_id
  db_engine           = var.db_engine
  db_engine_version   = var.db_engine_version
  db_instance_class   = var.db_instance_class
  db_name             = var.db_name
  db_username         = var.db_username
  multi_az            = var.multi_az
  deletion_protection = var.deletion_protection
}

################################################################################
# ElastiCache
################################################################################

module "elasticache" {
  source = "../../modules/elasticache"

  project_name       = var.project_name
  environment        = var.environment
  private_subnet_ids = module.vpc.private_subnet_ids
  security_group_id  = module.security_groups.elasticache_sg_id
  enable_redis       = var.enable_redis
  node_type          = var.redis_node_type
}
