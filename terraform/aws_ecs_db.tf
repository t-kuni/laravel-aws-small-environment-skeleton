resource "aws_ecs_cluster" "db" {
  name = "${var.project_name}_db"
}

//
// DBを実行するタスク
//
resource "aws_ecs_task_definition" "db" {
  family                = "${var.project_name}_db"
  memory                = "768"
  container_definitions = data.template_file.db.rendered
  execution_role_arn    = module.ecs_task_execution_role_db.iam_role_arn
  task_role_arn         = module.ecs_task_execution_role_db.iam_role_arn

  volume {
    name = "db-data"
    docker_volume_configuration {
      scope         = "shared"
      autoprovision = true
      driver        = "local"
    }
  }
}

resource "aws_ecs_service" "db" {
  name            = "${var.project_name}_db"
  cluster         = aws_ecs_cluster.db.id
  task_definition = aws_ecs_task_definition.db.arn
  desired_count   = 1
}

data "template_file" "db" {
  template = file("./task_definitions/db.json")
  vars = {
    project_name = var.project_name
  }
}

//
// DBを実行するタスクの権限
//
module "ecs_task_execution_role_db" {
  source     = "./iam_role"
  name       = "${var.project_name}_ecs_task_execution_db"
  identifier = "ecs-tasks.amazonaws.com"
  policy     = data.aws_iam_policy_document.ecs_task_execution_db.json
}

data "aws_iam_policy" "ecs_task_execution_role_policy_db" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

data "aws_iam_policy_document" "ecs_task_execution_db" {
  source_json = data.aws_iam_policy.ecs_task_execution_role_policy_db.policy

  statement {
    effect    = "Allow"
    actions   = ["ssm:GetParameters", "kms:Decrypt"]
    resources = ["*"]
  }
}

//
// ロギング
//
resource "aws_cloudwatch_log_group" "db" {
  name              = "/${var.project_name}/db"
  retention_in_days = 30
}


//
// DBをバックアップするタスク
//
resource "aws_ecs_task_definition" "db_backuper" {
  family                = "${var.project_name}_db_backuper"
  memory                = "64"
  container_definitions = data.template_file.db_backuper.rendered
  execution_role_arn    = module.ecs_task_execution_role_db_backuper.iam_role_arn
  task_role_arn         = module.ecs_task_execution_role_db_backuper.iam_role_arn
}

data "template_file" "db_backuper" {
  template = file("./task_definitions/db_backuper.json")
  vars = {
    project_name = var.project_name
  }
}

//
// バックアップ実行スケジュール
//
resource "aws_cloudwatch_event_rule" "db_backuper" {
  name = "${var.project_name}_db_backuper"
  description = "ビーコン管理システム　DBバックアップ"
  schedule_expression = "cron(0 17 * * ? *)" // 世界標準時で記載
  is_enabled = true
}

resource "aws_cloudwatch_event_target" "db_backuper" {
  target_id = "${var.project_name}_db_backuper"
  rule = aws_cloudwatch_event_rule.db_backuper.name
  role_arn = module.ecs_events_role.iam_role_arn
  arn = aws_ecs_cluster.db.arn

  ecs_target {
    launch_type = "EC2"
    task_count = 1
    task_definition_arn = aws_ecs_task_definition.db_backuper.arn
  }
}

module "ecs_events_role" {
  source = "./iam_role"
  name = "${var.project_name}_ecs_events"
  identifier = "events.amazonaws.com"
  policy = data.aws_iam_policy.ecs_events_role_policy.policy
}

data "aws_iam_policy" "ecs_events_role_policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceEventsRole"
}

//
// DBをバックアップするタスクの権限
//
module "ecs_task_execution_role_db_backuper" {
  source     = "./iam_role"
  name       = "${var.project_name}_ecs_task_execution_db_backuper"
  identifier = "ecs-tasks.amazonaws.com"
  policy     = data.aws_iam_policy_document.ecs_task_execution_db_backuper.json
}

data "aws_iam_policy" "ecs_task_execution_role_policy_db_backuper" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

data "aws_iam_policy_document" "ecs_task_execution_db_backuper" {
  source_json = data.aws_iam_policy.ecs_task_execution_role_policy_db_backuper.policy

  statement {
    effect    = "Allow"
    actions   = ["ssm:GetParameters", "kms:Decrypt"]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:PutObjectAcl"
    ]
    resources = [
      aws_s3_bucket.db_backup.arn,
      "${aws_s3_bucket.db_backup.arn}/*",
    ]
  }
}

//
// DBをバックアップするタスクのロギング
//
resource "aws_cloudwatch_log_group" "db_backuper" {
  name              = "/${var.project_name}/db_backuper"
  retention_in_days = 30
}
