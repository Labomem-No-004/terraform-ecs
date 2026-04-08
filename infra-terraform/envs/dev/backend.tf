# 로컬 state 사용
# S3 remote backend가 필요하면 아래 주석을 해제하세요.
#
# terraform {
#   backend "s3" {
#     bucket         = "my-project-terraform-state"
#     key            = "dev/terraform.tfstate"
#     region         = "ap-northeast-2"
#     encrypt        = true
#     dynamodb_table = "terraform-state-lock"
#   }
# }
