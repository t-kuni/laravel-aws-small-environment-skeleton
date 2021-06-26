//
// App
//
resource "aws_ssm_parameter" "APP_NAME" {
  name  = "/${var.project_name}_app/APP_NAME"
  type  = "String"
  value = "XXXX"
}

resource "aws_ssm_parameter" "APP_ENV" {
  name  = "/${var.project_name}_app/APP_ENV"
  type  = "String"
  value = "development"
}

resource "aws_ssm_parameter" "APP_KEY" {
  name  = "/${var.project_name}_app/APP_KEY"
  type  = "SecureString"
  value = "dummy"

  lifecycle {
    ignore_changes = [
    value]
  }
}

resource "aws_ssm_parameter" "APP_DEBUG" {
  name  = "/${var.project_name}_app/APP_DEBUG"
  type  = "String"
  value = "true"
}

resource "aws_ssm_parameter" "APP_URL" {
  name  = "/${var.project_name}_app/APP_URL"
  type  = "String"
  value = "https://XXXX.com"
}

resource "aws_ssm_parameter" "LOG_CHANNEL" {
  name  = "/${var.project_name}_app/LOG_CHANNEL"
  type  = "String"
  value = "stack"
}

resource "aws_ssm_parameter" "LOG_LEVEL" {
  name  = "/${var.project_name}_app/LOG_LEVEL"
  type  = "String"
  value = "debug"
}

resource "aws_ssm_parameter" "DB_CONNECTION" {
  name  = "/${var.project_name}_app/DB_CONNECTION"
  type  = "String"
  value = "mysql"
}

resource "aws_ssm_parameter" "DB_HOST" {
  name  = "/${var.project_name}_app/DB_HOST"
  type  = "String"
  value = "db"
}

resource "aws_ssm_parameter" "DB_PORT" {
  name  = "/${var.project_name}_app/DB_PORT"
  type  = "String"
  value = "3306"
}

resource "aws_ssm_parameter" "DB_DATABASE" {
  name  = "/${var.project_name}_app/DB_DATABASE"
  type  = "String"
  value = "test"
}

resource "aws_ssm_parameter" "DB_USERNAME" {
  name  = "/${var.project_name}_app/DB_USERNAME"
  type  = "String"
  value = "root"
}

resource "aws_ssm_parameter" "DB_PASSWORD" {
  name  = "/${var.project_name}_app/DB_PASSWORD"
  type  = "SecureString"
  value = "dummy"

  lifecycle {
    ignore_changes = [
    value]
  }
}

resource "aws_ssm_parameter" "BROADCAST_DRIVER" {
  name  = "/${var.project_name}_app/BROADCAST_DRIVER"
  type  = "String"
  value = "log"
}

resource "aws_ssm_parameter" "CACHE_DRIVER" {
  name  = "/${var.project_name}_app/CACHE_DRIVER"
  type  = "String"
  value = "redis"
}

resource "aws_ssm_parameter" "FILESYSTEM_DRIVER" {
  name  = "/${var.project_name}_app/FILESYSTEM_DRIVER"
  type  = "String"
  value = "local"
}

resource "aws_ssm_parameter" "QUEUE_CONNECTION" {
  name  = "/${var.project_name}_app/QUEUE_CONNECTION"
  type  = "String"
  value = "sync"
}

resource "aws_ssm_parameter" "SESSION_DRIVER" {
  name  = "/${var.project_name}_app/SESSION_DRIVER"
  type  = "String"
  value = "file"
}

resource "aws_ssm_parameter" "SESSION_LIFETIME" {
  name  = "/${var.project_name}_app/SESSION_LIFETIME"
  type  = "String"
  value = "120"
}

resource "aws_ssm_parameter" "MEMCACHED_HOST" {
  name  = "/${var.project_name}_app/MEMCACHED_HOST"
  type  = "String"
  value = "127.0.0.1"
}

resource "aws_ssm_parameter" "REDIS_HOST" {
  name  = "/${var.project_name}_app/REDIS_HOST"
  type  = "String"
  value = "kvs"
}

resource "aws_ssm_parameter" "REDIS_PASSWORD" {
  name  = "/${var.project_name}_app/REDIS_PASSWORD"
  type  = "SecureString"
  value = "dummy"
}

resource "aws_ssm_parameter" "REDIS_PORT" {
  name  = "/${var.project_name}_app/REDIS_PORT"
  type  = "String"
  value = "6379"
}

resource "aws_ssm_parameter" "MAIL_MAILER" {
  name  = "/${var.project_name}_app/MAIL_MAILER"
  type  = "String"
  value = "smtp"
}

resource "aws_ssm_parameter" "MAIL_HOST" {
  name  = "/${var.project_name}_app/MAIL_HOST"
  type  = "String"
  value = "mailhog"
}

resource "aws_ssm_parameter" "MAIL_PORT" {
  name  = "/${var.project_name}_app/MAIL_PORT"
  type  = "String"
  value = "1025"
}

resource "aws_ssm_parameter" "MAIL_USERNAME" {
  name  = "/${var.project_name}_app/MAIL_USERNAME"
  type  = "String"
  value = "null"
}

resource "aws_ssm_parameter" "MAIL_PASSWORD" {
  name  = "/${var.project_name}_app/MAIL_PASSWORD"
  type  = "SecureString"
  value = "dummy"

  lifecycle {
    ignore_changes = [
    value]
  }
}

resource "aws_ssm_parameter" "MAIL_ENCRYPTION" {
  name  = "/${var.project_name}_app/MAIL_ENCRYPTION"
  type  = "String"
  value = "null"
}

resource "aws_ssm_parameter" "MAIL_FROM_ADDRESS" {
  name  = "/${var.project_name}_app/MAIL_FROM_ADDRESS"
  type  = "String"
  value = "null"
}

resource "aws_ssm_parameter" "MAIL_FROM_NAME" {
  name  = "/${var.project_name}_app/MAIL_FROM_NAME"
  type  = "String"
  value = "$${APP_NAME}"
}

resource "aws_ssm_parameter" "AWS_ACCESS_KEY_ID" {
  name  = "/${var.project_name}_app/AWS_ACCESS_KEY_ID"
  type  = "String"
  value = ""
}

resource "aws_ssm_parameter" "AWS_SECRET_ACCESS_KEY" {
  name  = "/${var.project_name}_app/AWS_SECRET_ACCESS_KEY"
  type  = "String"
  value = ""
}

resource "aws_ssm_parameter" "AWS_DEFAULT_REGION" {
  name  = "/${var.project_name}_app/AWS_DEFAULT_REGION"
  type  = "String"
  value = "us-east-1"
}

resource "aws_ssm_parameter" "AWS_BUCKET" {
  name  = "/${var.project_name}_app/AWS_BUCKET"
  type  = "String"
  value = ""
}

//
// DB
//
resource "aws_ssm_parameter" "MYSQL_ROOT_PASSWORD" {
  name  = "/${var.project_name}_db/MYSQL_ROOT_PASSWORD"
  type  = "SecureString"
  value = "dummy"

  lifecycle {
    ignore_changes = [
    value]
  }
}

//
// DB-BACKUPER
//
resource "aws_ssm_parameter" "DB_BACKUP_BUCKET_NAME" {
  name  = "/${var.project_name}_db_backuper/DB_BACKUP_BUCKET_NAME"
  type  = "String"
  value = "dummy"
}

resource "aws_ssm_parameter" "DB_BACKUPER_DB_HOST" {
  name  = "/${var.project_name}_db_backuper/DB_HOST"
  type  = "String"
  value = "dummy"
}

resource "aws_ssm_parameter" "DB_BACKUPER_DB_USERNAME" {
  name  = "/${var.project_name}_db_backuper/DB_USERNAME"
  type  = "String"
  value = "dummy"
}
