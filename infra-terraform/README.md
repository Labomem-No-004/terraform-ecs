# AWS ECS Terraform 템플릿

개인 프로젝트용 AWS 인프라 Terraform 템플릿입니다.

## 아키텍처 구성

- **VPC**: 퍼블릭/프라이빗 서브넷 2AZ, NAT Gateway
- **ALB**: Application Load Balancer (HTTP/HTTPS)
- **ECS Fargate**: 컨테이너 기반 서비스 운영
- **ECR**: Docker 이미지 레지스트리
- **RDS**: PostgreSQL 또는 MySQL 데이터베이스
- **ElastiCache**: Redis 캐시

## 프로젝트 구조

```
infra-terraform/
├── modules/           # 재사용 가능한 Terraform 모듈
│   ├── vpc/           # VPC, 서브넷, NAT Gateway
│   ├── security_groups/  # 보안그룹 (ALB, ECS, RDS, Redis, Bastion)
│   ├── alb/           # Application Load Balancer
│   ├── ecr/           # ECR 레포지토리
│   ├── ecs/           # ECS Cluster, Service, Task Definition, Auto Scaling
│   ├── rds/           # RDS 인스턴스 + Secrets Manager
│   └── elasticache/   # ElastiCache Redis
├── envs/
│   ├── dev/           # 개발 환경
│   └── prod/          # 운영 환경
└── README.md
```

## 빠른 시작

### 1. 사전 준비

- Terraform >= 1.5
- AWS CLI 설정 완료 (`aws configure`)
- S3 backend 버킷 및 DynamoDB lock 테이블 생성

```bash
# S3 backend 버킷 생성 (최초 1회)
aws s3 mb s3://my-project-terraform-state --region ap-northeast-2

# DynamoDB lock 테이블 생성 (최초 1회)
aws dynamodb create-table \
  --table-name terraform-state-lock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region ap-northeast-2
```

### 2. 환경별 설정

`envs/dev/terraform.tfvars` 또는 `envs/prod/terraform.tfvars`를 프로젝트에 맞게 수정합니다.

```hcl
# 프로젝트명 변경
project_name = "my-new-project"

# DB 설정
db_engine = "postgres"   # 또는 "mysql"
db_name   = "mydb"

# ECS 서비스 정의
ecs_services = {
  api = {
    cpu               = 256
    memory            = 512
    port              = 8080
    desired_count     = 1
    health_check_path = "/health"
  }
  worker = {
    cpu               = 256
    memory            = 512
    port              = 8080
    desired_count     = 1
    health_check_path = "/health"
  }
}
```

### 3. 인프라 배포

```bash
cd envs/dev
terraform init
terraform plan
terraform apply
```

### 4. 인프라 제거

```bash
cd envs/dev
terraform destroy
```

## 주요 변수

| 변수 | 설명 | 기본값 |
|------|------|--------|
| `project_name` | 프로젝트 이름 (리소스 네이밍에 사용) | - (필수) |
| `environment` | 환경 (dev, staging, prod) | dev/prod |
| `aws_region` | AWS 리전 | ap-northeast-2 |
| `vpc_cidr` | VPC CIDR 블록 | 10.0.0.0/16 |
| `enable_nat_gateway` | NAT Gateway 활성화 | dev: false / prod: true |
| `enable_nat_instance` | NAT Instance 활성화 (비용 절감) | dev: true / prod: false |
| `enable_https` | HTTPS 리스너 활성화 | false |
| `acm_certificate_arn` | ACM 인증서 ARN | "" |
| `db_engine` | DB 엔진 (postgres/mysql) | postgres |
| `db_instance_class` | RDS 인스턴스 클래스 | db.t3.micro |
| `db_name` | 데이터베이스 이름 | - (필수) |
| `multi_az` | RDS Multi-AZ 배포 | false |
| `deletion_protection` | RDS 삭제 방지 | false |
| `ecr_repo_names` | ECR 레포지토리 이름 목록 | ["api"] |
| `ecs_services` | ECS 서비스 설정 맵 | {} |
| `enable_redis` | ElastiCache Redis 활성화 | true |
| `enable_bastion` | Bastion SG 생성 | false |

## 환경별 차이점

| 항목 | dev | prod |
|------|-----|------|
| VPC CIDR | 10.0.0.0/16 | 10.1.0.0/16 |
| NAT | NAT Instance (t3.micro) | NAT Gateway |
| ECS CPU/Memory | 256/512 | 512/1024 |
| ECS desired_count | 1 | 2 |
| RDS 인스턴스 | db.t3.micro | db.t3.small |
| Multi-AZ | off | on |
| deletion_protection | off | on |
| HTTPS | off | on |
| Redis 노드 | cache.t3.micro | cache.t3.small |

## 리소스 네이밍 규칙

모든 리소스는 `{project_name}-{environment}-{용도}` 형식으로 네이밍됩니다.

예시: `myproject-dev-vpc`, `myproject-prod-alb-sg`

## 태그 규칙

모든 리소스에 아래 태그가 자동 적용됩니다:

- `Project` = project_name
- `Environment` = environment
- `ManagedBy` = "terraform"

## 보안 참고사항

- RDS 마스터 비밀번호는 `random_password`로 자동 생성되어 AWS Secrets Manager에 저장됩니다.
- 모든 데이터베이스와 캐시는 프라이빗 서브넷에 배치됩니다.
- ECS 태스크는 ALB를 통해서만 접근 가능합니다.
- 민감한 변수에는 `sensitive = true`가 설정되어 있습니다.

## 사용 체크리스트

1. `terraform.tfvars`에서 `project_name`, `db_name` 설정
2. `backend.tf`에서 S3 버킷명과 key 변경 (또는 로컬 state 사용 시 backend.tf 비우기)
3. `ecs_services`에서 서비스 정의
4. `ecr_repo_names`에서 필요한 ECR 레포 정의
5. HTTPS 사용 시 ACM 인증서 ARN 설정
