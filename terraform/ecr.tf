resource "aws_ecr_repository" "app" {
  name                 = "deswik-app"
  image_tag_mutability = "MUTABLE" # Allow overwrite of existing tags

  image_scanning_configuration {
    scan_on_push = true # Scan images for security vulnerabilities when pushed to repo
  }
}
