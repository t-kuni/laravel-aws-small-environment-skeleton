// app
resource "aws_ecr_repository" "app" {
  name = "${var.project_name}_app"
}

resource "aws_ecr_lifecycle_policy" "app" {
  repository = aws_ecr_repository.app.name
  policy     = local.policy
}

// web
resource "aws_ecr_repository" "web" {
  name = "${var.project_name}_web"
}

resource "aws_ecr_lifecycle_policy" "web" {
  repository = aws_ecr_repository.web.name
  policy     = local.policy
}

// db
resource "aws_ecr_repository" "db" {
  name = "${var.project_name}_db"
}

resource "aws_ecr_lifecycle_policy" "db" {
  repository = aws_ecr_repository.db.name
  policy     = local.policy
}

// kvs
resource "aws_ecr_repository" "kvs" {
  name = "${var.project_name}_kvs"
}

resource "aws_ecr_lifecycle_policy" "kvs" {
  repository = aws_ecr_repository.kvs.name
  policy     = local.policy
}

// db-backuper
resource "aws_ecr_repository" "db_backuper" {
  name = "${var.project_name}_db_backuper"
}

resource "aws_ecr_lifecycle_policy" "db_backuper" {
  repository = aws_ecr_repository.db_backuper.name
  policy     = local.policy
}

locals {
  policy = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Keep last 10 images",
            "selection": {
                "tagStatus": "tagged",
                "tagPrefixList": ["v"],
                "countType": "imageCountMoreThan",
                "countNumber": 10
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF
}
