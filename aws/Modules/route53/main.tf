# Looks up an existing hosted zone by name - never creates or manages the
# zone itself. A shared, customer-facing zone is exactly the kind of
# resource you don't want a module able to recreate or delete by accident.
data "aws_route53_zone" "this" {
  name         = var.zone_name
  private_zone = var.private_zone
}

resource "aws_route53_record" "this" {
  zone_id = data.aws_route53_zone.this.zone_id
  name    = var.record_name
  type    = var.record_type

  alias {
    name                   = var.alias_target_dns_name
    zone_id                = var.alias_target_zone_id
    evaluate_target_health = var.evaluate_target_health
  }
}
