resource "aws_iam_role_policy_attachment" "attached" {
  count      = length(var.roles) * length(var.policies)
  role       = reverse(split("/", var.roles[count.index % length(var.roles)]))[0]
  policy_arn = var.policies[count.index % length(var.policies)]
}
