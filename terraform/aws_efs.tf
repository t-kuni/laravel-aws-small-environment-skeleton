//
// appサーバの永続化データを保持しています
// 削除しないようにしてください
//
resource "aws_efs_file_system" "app_storage" {
  creation_token = "${var.project_name}_app_storage"

  tags = {
    Name = "${var.project_name}_app_storage"
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_efs_mount_target" "alpha" {
  file_system_id  = aws_efs_file_system.app_storage.id
  subnet_id       = aws_subnet.default.id
  security_groups = [aws_security_group.app_storage.id]
}

resource "aws_security_group" "app_storage" {
  name   = "${var.project_name}_app_storage"
  vpc_id = aws_vpc.default.id

  ingress {
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [aws_security_group.app.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}_app_storage"
  }
}

//
// バックアップ
//
resource "aws_backup_plan" "app_storage" {
  name = "${var.project_name}_app_storage"

  rule {
    rule_name                = "${var.project_name}_app_storage"
    enable_continuous_backup = false
    schedule                 = "cron(0 17 ? * * *)" // 世界標準時で記載
    start_window             = 60
    completion_window        = 120
    target_vault_name        = aws_backup_vault.app_storage.name

    lifecycle {
      cold_storage_after = 0
      delete_after       = 7
    }
  }
}

resource "aws_backup_vault" "app_storage" {
  name        = "${var.project_name}_app_storage"
  kms_key_arn = "arn:aws:kms:ap-northeast-1:XXXX:key/37265a63-24ac-4d70-a90e-01b1a04c194c" // AWS Backupのデフォルトキー
}

resource "aws_backup_selection" "app_storage" {
  name         = "${var.project_name}_app_storage"
  iam_role_arn = "arn:aws:iam::XXXX:role/service-role/AWSBackupDefaultServiceRole"
  plan_id      = aws_backup_plan.app_storage.id

  resources = [
    aws_efs_file_system.app_storage.arn
  ]
}
