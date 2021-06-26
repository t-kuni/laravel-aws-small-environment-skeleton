variable "project_name" {
  default = "XXXX_XXXX"
}

variable "project_name_hyphen" {
  default = "XXXX-XXXX"
}

variable "db_private_ip" {
  default = "10.0.0.10"
}

variable "aws_access_key_id" {
  sensitive = true
}
variable "aws_secret_access_key" {
  sensitive = true
}
