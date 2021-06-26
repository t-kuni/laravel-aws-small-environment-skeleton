resource "aws_s3_bucket" "db_backup" {
  bucket = "${var.project_name_hyphen}-db-backup"
  acl    = "private"

  lifecycle_rule {
    abort_incomplete_multipart_upload_days = 0
    enabled                                = true
    id                                     = "${var.project_name}_db_backup"
    tags                                   = {}

    noncurrent_version_expiration {
      days = 7
    }
  }

  server_side_encryption_configuration {
    rule {
      bucket_key_enabled = false

      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}
