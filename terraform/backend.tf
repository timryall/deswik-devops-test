terraform {
  backend "s3" {
    bucket         = "timryall-terraform-state"
    key            = "app/terraform.tfstate"
    region         = "ap-southeast-2"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}