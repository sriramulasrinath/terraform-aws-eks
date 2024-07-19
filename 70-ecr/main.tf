resource "aws_ecr_repository" "backend" {
  name                 = "${var.project_name}-backend"
  image_tag_mutability = "IMMUTABLE" # if u update the tag it will  create new image. current image not affected 

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "frontend" {
  name                 = "${var.project_name}-frontend"
  image_tag_mutability = "IMMUTABLE" # if u update the tag it will  create new image. current image not affected 

  image_scanning_configuration {
    scan_on_push = true
  }
}