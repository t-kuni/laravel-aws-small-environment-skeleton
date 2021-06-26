resource "aws_ecs_cluster" "app" {
  name = "${var.project_name}_app"
}

// app task
resource "aws_ecs_task_definition" "app" {
  family                = "${var.project_name}_app"
  memory                = "768"
  container_definitions = data.template_file.app.rendered
  execution_role_arn    = module.ecs_task_execution_role.iam_role_arn
  task_role_arn         = module.ecs_task_execution_role.iam_role_arn

  volume {
    name = "storage"
    efs_volume_configuration {
      file_system_id = aws_efs_file_system.app_storage.id
    }
  }
}

resource "aws_ecs_service" "app" {
  name            = "${var.project_name}_app"
  cluster         = aws_ecs_cluster.app.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = 1
}

data "template_file" "app" {
  template = file("./task_definitions/app.json")
  vars = {
    project_name  = var.project_name
    db_private_ip = var.db_private_ip
  }
}

//
// IAM
//
module "ecs_task_execution_role" {
  source     = "./iam_role"
  name       = "${var.project_name}_ecs_task_execution"
  identifier = "ecs-tasks.amazonaws.com"
  policy     = data.aws_iam_policy_document.ecs_task_execution.json
}

data "aws_iam_policy" "ecs_task_execution_role_policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

data "aws_iam_policy_document" "ecs_task_execution" {
  source_json = data.aws_iam_policy.ecs_task_execution_role_policy.policy

  statement {
    effect    = "Allow"
    actions   = ["ssm:GetParameters", "kms:Decrypt"]
    resources = ["*"]
  }
}

//
// ロギング
//
resource "aws_cloudwatch_log_group" "app" {
  name              = "/${var.project_name}/app"
  retention_in_days = 30
}

resource "aws_cloudwatch_log_group" "web" {
  name              = "/${var.project_name}/web"
  retention_in_days = 30
}

resource "aws_cloudwatch_log_group" "scheduler" {
  name              = "/${var.project_name}/scheduler"
  retention_in_days = 30
}

resource "aws_cloudwatch_log_group" "kvs" {
  name              = "/${var.project_name}/kvs"
  retention_in_days = 30
}
