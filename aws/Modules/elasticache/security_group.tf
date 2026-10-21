# Based on a real finding: a dev cache cluster had its port open to
# 0.0.0.0/0, and the compute actually using it wasn't allowlisted at all -
# the only security group referenced by name belonged to a long-retired
# service. Everything "worked" purely because of the open rule, so the day
# someone correctly tightened it, the live app would have silently lost its
# cache. Allowlisting by security group reference (one rule per consumer)
# makes the real dependency explicit and leaves nothing open by accident.
resource "aws_security_group" "this" {
  name        = "${var.name_prefix}-cache-sg"
  description = "${var.engine} cache - ingress from allowlisted security groups only"
  vpc_id      = var.vpc_id

  tags = { Name = "${var.name_prefix}-cache-sg" }
}

resource "aws_vpc_security_group_ingress_rule" "from_allowed_sg" {
  for_each = toset(var.allowed_security_group_ids)

  security_group_id            = aws_security_group.this.id
  ip_protocol                  = "tcp"
  from_port                    = var.port
  to_port                      = var.port
  referenced_security_group_id = each.value
  description                  = "Cache port from ${each.value}"
}

# No egress rule on purpose. A cache node never initiates outbound
# connections to clients - replies to inbound connections are allowed by
# security group statefulness regardless of egress rules.
