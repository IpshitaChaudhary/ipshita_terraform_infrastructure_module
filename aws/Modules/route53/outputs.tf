output "zone_id" {
  description = "ID of the hosted zone the record was created in."
  value       = data.aws_route53_zone.this.zone_id
}

output "record_fqdn" {
  description = "Fully-qualified name of the record created."
  value       = aws_route53_record.this.fqdn
}
