terraform {
  backend "s3" {
    bucket = "XXXX-tfstate"
    key    = "terraform.tfstate"
    region = "ap-northeast-1"
  }
}
