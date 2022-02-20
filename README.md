# modules/assume-role

## Features

1. Define IAM user and iam assumable role
1. Create assume role script

## Module Usage

```hcl
module "this" {
  source = "github.com/bigflood/terraform-modules//modules/assume-role"

  name            = "infra-dev"
  script_filename = "${path.module}/assume-role-bash.sh"

  additional_role_policy_document = jsonencode({
    "Version" = "2012-10-17",
    "Statement" = [
      {
        "Action" = [
          "iam:UpdateAssumeRolePolicy",
          "iam:CreatePolicy",
          "iam:DeletePolicy",
          "iam:CreateRole",
          "iam:DeleteRole",
          "iam:PassRole",
          "iam:AttachRolePolicy",
          "iam:DetachRolePolicy",
          "iam:CreateOpenIDConnectProvider",
          "iam:DeleteOpenIDConnectProvider",
          "iam:Tag*",
        ],
        "Effect"   = "Allow",
        "Resource" = "*"
      }
    ]
  })

  tags = {
    Terrraform  = "true"
    Environment = "dev"
  }
}
```

## Assume role script

to run generated script, you need to enable MFA of IAM user(ex: infra-dev)

https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_mfa_enable_virtual.html

### Usage

```bash
$ ./assume-role.sh MFA_token
```

### example

```bash
$ ./assume-role.sh 123456
Expiration: 2022-02-22T22:22:22Z
...

$ (AWSCLI-assume-role) aws sts get-caller-identity
{
    "UserId": "********:AWSCLI-assume-role",
    "Account": "******",
    "Arn": "arn:aws:sts::******:assumed-role/infra-dev-role/AWSCLI-assume-role"
}

$ (AWSCLI-assume-role) exit

$ aws sts get-caller-identity
{
    "UserId": "********",
    "Account": "******",
    "Arn": "arn:aws:iam::******:user/infra-dev"
}
```

## Pre-requisites

- terraform
- jq
- awscli

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Desired name for the IAM user | `string` | n/a | yes |
| additional_role_policy_document | additional policy document for assumable role | `string` | `""` | no |
| script_filename | assume role script filename | `string` | `""` | no |
| tags | A map of tags to add to all resources. | `map(string)` | `{}` | no |
