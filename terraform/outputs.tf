output "repository_url_app" {
  value = aws_ecr_repository.app.repository_url
}

output "repository_url_web" {
  value = aws_ecr_repository.web.repository_url
}

output "repository_url_db" {
  value = aws_ecr_repository.db.repository_url
}
