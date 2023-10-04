resource "aws_ecr_repository" "global-infra" {
  for_each = var.ecr-repos
  name = each.value.name
  image_tag_mutability = each.value.mutability
  image_scanning_configuration {
    scan_on_push = each.value.scan_on_push
  }
}