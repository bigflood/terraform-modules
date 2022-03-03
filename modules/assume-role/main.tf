
locals {
  name            = var.name
  script_filename = var.script_filename
  account_id      = data.aws_caller_identity.current.account_id
  tags            = var.tags
}

data "aws_caller_identity" "current" {}

# https://github.com/terraform-aws-modules/terraform-aws-iam/tree/master/modules/iam-user
module "iam_user" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-user"
  version = "~> 4"

  name                          = local.name
  create_iam_user_login_profile = false
  create_iam_access_key         = false
  force_destroy                 = true
  tags                          = local.tags
}

# https://github.com/terraform-aws-modules/terraform-aws-iam
module "iam_assumable_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "~> 4"

  trusted_role_arns = [
    module.iam_user.iam_user_arn,
  ]

  create_role = true

  role_name = "${local.name}-role"

  attach_readonly_policy  = true
  attach_poweruser_policy = true
  role_requires_mfa       = true
  max_session_duration    = var.max_session_duration

  custom_role_policy_arns = module.iam_assumable_role_policy.*.id

  tags = local.tags
}

module "iam_assumable_role_policy" {
  count = var.additional_role_policy_document != "" ? 1 : 0

  source = "terraform-aws-modules/iam/aws//modules/iam-policy"
  name   = "${local.name}-role-policy"

  policy = var.additional_role_policy_document

  tags = local.tags
}

resource "local_file" "assume_role_script" {
  count           = local.script_filename != "" ? 1 : 0
  filename        = local.script_filename
  file_permission = "0755"
  content         = <<EOF
#!/bin/bash

set -eu -o pipefail

session_name='AWSCLI-${local.name}'

output=$(aws sts assume-role \
    --role-arn "arn:aws:iam::${local.account_id}:role/${local.name}-role" \
    --role-session-name "$session_name"  \
    --serial-number arn:aws:iam::${local.account_id}:mfa/${local.name} \
    --token-code "$1")

AccessKeyId=$(echo $output | jq -r '.Credentials.AccessKeyId')
SecretAccessKey=$(echo $output | jq -r '.Credentials.SecretAccessKey')
SessionToken=$(echo $output | jq -r '.Credentials.SessionToken')
Expiration=$(echo $output | jq -r '.Credentials.Expiration')

echo "Expiration: $Expiration"

export AWS_ACCESS_KEY_ID="$AccessKeyId"
export AWS_SECRET_ACCESS_KEY="$SecretAccessKey"
export AWS_SESSION_TOKEN="$SessionToken"

aws sts get-caller-identity

bash --init-file <(echo ". \"$HOME/.bashrc\"; PS1+='($session_name) '")
EOF

}
