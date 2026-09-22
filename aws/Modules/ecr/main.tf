# Both repositories are expected to already exist (created elsewhere, e.g.
# by a separate bootstrap/CI project) - referenced here as data sources only,
# never declared/managed as resources, so an apply can't touch or recreate them.
data "aws_ecr_repository" "backend" {
  name = var.backend_repository_name
}

data "aws_ecr_repository" "frontend" {
  name = var.frontend_repository_name
}
