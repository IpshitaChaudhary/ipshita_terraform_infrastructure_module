output "primary_endpoint_address" {
  description = "Write endpoint. Clients must connect with TLS (e.g. rediss://), since transit encryption is always on."
  value       = aws_elasticache_replication_group.this.primary_endpoint_address
}

output "reader_endpoint_address" {
  description = "Load-balanced read endpoint across replicas - only useful when num_cache_clusters > 1."
  value       = aws_elasticache_replication_group.this.reader_endpoint_address
}

output "port" {
  description = "Port clients connect to."
  value       = aws_elasticache_replication_group.this.port
}

output "security_group_id" {
  description = "The cache's own security group - add new consumers via allowed_security_group_ids, not by attaching extra rules to this group out of band."
  value       = aws_security_group.this.id
}
