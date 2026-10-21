resource "aws_elasticache_subnet_group" "this" {
  name       = "${var.name_prefix}-cache-subnets"
  subnet_ids = var.subnet_ids
}

# A replication group even for a single node, rather than a standalone
# aws_elasticache_cluster - it's the only resource that supports in-transit
# encryption and AUTH, and growing from 1 node to a primary + replicas later
# is a num_cache_clusters change instead of a destroy-and-recreate.
resource "aws_elasticache_replication_group" "this" {
  replication_group_id = "${var.name_prefix}-cache"
  description          = "${var.name_prefix} ${var.engine} cache"

  engine         = var.engine
  engine_version = var.engine_version
  node_type      = var.node_type
  port           = var.port

  num_cache_clusters         = var.num_cache_clusters
  automatic_failover_enabled = var.num_cache_clusters > 1
  multi_az_enabled           = var.num_cache_clusters > 1

  subnet_group_name  = aws_elasticache_subnet_group.this.name
  security_group_ids = [aws_security_group.this.id]

  # Both always on - not exposed as toggles. Turning on at-rest encryption
  # later forces a replacement of the whole replication group, so it has to
  # be right from day one.
  at_rest_encryption_enabled = true
  kms_key_id                 = var.kms_key_id
  transit_encryption_enabled = true
  auth_token                 = var.auth_token

  snapshot_retention_limit = var.snapshot_retention_limit

  # Engine/patch changes wait for the maintenance window instead of
  # restarting nodes mid-day on a plain `terraform apply`.
  apply_immediately = false

  tags = { Name = "${var.name_prefix}-cache" }
}
