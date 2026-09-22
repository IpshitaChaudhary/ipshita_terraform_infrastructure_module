# Turns a flat list of secret key names into the {name, valueFrom} shape the
# ECS task definition's `secrets` block expects, all pointing at the same
# Secrets Manager secret ARN. Skips itself entirely if no secret was supplied.
locals {
  backend_container_secrets = var.backend_secret_name == "" ? [] : [
    for name in var.backend_secret_env_names : {
      name      = name
      valueFrom = "${module.secrets[0].backend_env_secret_arn}:${name}::"
    }
  ]
}
