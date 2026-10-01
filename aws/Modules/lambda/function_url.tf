# Opt-in and authenticated by default - a real account audit found a
# function URL with AuthType "NONE", publicly invocable by anyone who
# found or guessed the URL, live for years with zero authentication.
# This module creates no function URL at all unless enable_function_url
# is explicitly set, and even then defaults to AWS_IAM - a caller has to
# deliberately choose "NONE" (e.g. for a genuine public webhook) rather
# than get it by omission.
resource "aws_lambda_function_url" "this" {
  count = var.enable_function_url ? 1 : 0

  function_name      = aws_lambda_function.this.function_name
  authorization_type = var.function_url_auth_type
}
