# Human (console/CLI) access groups - separate concern from the ECS task
# roles above. Opt-in and empty by default: this module doesn't assume every
# caller wants it managing human IAM groups versus that being handled
# elsewhere (SSO/Identity Center, a separate account-baseline stack).
#
# Deliberately data-driven (a map variable) rather than a fixed set of named
# groups baked into the module - the real tiers an account needs (how many,
# what each is called, which managed policies it gets) vary per org, and
# hardcoding them here would force every caller into one team's structure.
resource "aws_iam_group" "this" {
  for_each = var.human_access_groups
  name     = each.key
}

resource "aws_iam_group_policy_attachment" "this" {
  for_each = {
    for pair in flatten([
      for group_name, policy_arns in var.human_access_groups : [
        for policy_arn in policy_arns : {
          key        = "${group_name}-${policy_arn}"
          group_name = group_name
          policy_arn = policy_arn
        }
      ]
    ]) : pair.key => pair
  }

  group      = aws_iam_group.this[each.value.group_name].name
  policy_arn = each.value.policy_arn
}
