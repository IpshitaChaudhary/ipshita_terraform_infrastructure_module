variable "name_prefix" {
  description = "Prefix applied to every resource name/tag this module creates."
  type        = string
}

variable "vpc_id" {
  description = "VPC the cache's security group is created in."
  type        = string
}

variable "subnet_ids" {
  description = "Private subnet IDs for the cache subnet group - one per AZ you want a node in. Never public subnets; nothing outside the VPC should ever be able to route to a cache node."
  type        = list(string)
}

variable "engine" {
  description = "Cache engine. Valkey is the open-source, wire-compatible Redis fork and is cheaper on ElastiCache than the redis engine for the same node type."
  type        = string
  default     = "valkey"

  validation {
    condition     = contains(["valkey", "redis"], var.engine)
    error_message = "engine must be \"valkey\" or \"redis\" (memcached isn't supported by this module - no replication, no auth, no in-transit encryption parity)."
  }
}

variable "engine_version" {
  type    = string
  default = "8.0"
}

variable "node_type" {
  type    = string
  default = "cache.t4g.micro"
}

variable "port" {
  type    = number
  default = 6379
}

variable "num_cache_clusters" {
  description = "Total nodes (1 primary + N-1 replicas). 2+ enables automatic failover and Multi-AZ; 1 is fine for dev but has no failover at all."
  type        = number
  default     = 2
}

variable "allowed_security_group_ids" {
  description = "Security groups (ECS instances, Lambda, App Runner VPC connector, etc.) allowed to reach the cache port. Ingress is ONLY ever granted by security group reference - this module has no CIDR-based ingress input at all, so there's no way to accidentally open the cache port to 0.0.0.0/0 through it."
  type        = list(string)
}

variable "auth_token" {
  description = "Optional AUTH token (16-128 chars) required by clients on connect. Requires transit encryption, which this module always enables. Pass it from a secret store, never a literal in tfvars."
  type        = string
  default     = null
  sensitive   = true
}

variable "kms_key_id" {
  description = "Customer-managed KMS key ARN for encryption at rest. Leave null to use the ElastiCache-managed key - either way, at-rest encryption is always on."
  type        = string
  default     = null
}

variable "snapshot_retention_limit" {
  description = "Days of automatic daily snapshots to keep. 0 disables snapshots entirely."
  type        = number
  default     = 3
}
