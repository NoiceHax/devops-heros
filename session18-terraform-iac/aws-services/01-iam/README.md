# IAM: Identity and Access Management (Governance)

**What it is:** the AWS service that decides *who* can do *what* on *which* resources. It is global (not per region) and free.
Every API call is evaluated by IAM: authenticate (who are you?), then authorize (is this action allowed?).

| Concept | Meaning |
|---|---|
| **User** | A long-lived identity for a person or program, with a password and/or access keys |
| **Group** | A set of users that share permissions (a group is not an identity; it cannot be "logged in as") |
| **Role** | An identity with **no permanent credentials** that a trusted party *assumes* and gets temporary ones (EC2 instances, Lambda, CI jobs, other accounts) |
| **Policy** | A JSON document of statements: `Effect` (Allow/Deny), `Action`, `Resource`, optional `Condition` |
| **Permissions** | The result of all policies that apply to an identity (identity policies, resource policies, boundaries, SCPs) |

**Evaluation rule:** everything is denied by default; an explicit `Allow` is needed; an explicit `Deny` always wins.

## Hands-on (LocalStack, `transcripts/s18/11-aws-services-cli.txt`)

```bash
awslocal iam create-user  --user-name dev-user
awslocal iam create-group --group-name developers
awslocal iam add-user-to-group --user-name dev-user --group-name developers
awslocal iam create-policy --policy-name s3-read-demo-bucket --policy-document file://s3-read.json
awslocal iam attach-group-policy --group-name developers --policy-arn arn:aws:iam::000000000000:policy/s3-read-demo-bucket
awslocal iam create-role --role-name ec2-app-role --assume-role-policy-document file://trust.json
```

The policy allows only `s3:GetObject` and `s3:ListBucket` on one bucket, so `dev-user` inherits read-only access through the
group. The role's *trust policy* names `ec2.amazonaws.com`, meaning only EC2 may assume it.

## Least privilege

Grant the minimum actions on the minimum resources for the minimum time. Start from nothing and add; avoid
`"Action": "*"` / `"Resource": "*"`. Tighten using `Condition` (source IP, MFA, tags) and review with IAM Access Analyzer
and last-used data.

## Best practices

- Never use the root account for daily work; enable MFA on it and lock it away.
- Give permissions to **groups or roles**, not directly to users.
- Prefer **roles and temporary credentials** over access keys; never commit keys to Git (see session 17, secret scanning).
- Rotate or delete unused keys; use IAM Identity Center (SSO) for people.
- Use permission boundaries / SCPs as guardrails in multi-account setups; log everything with CloudTrail.

## Common use cases

An EC2 instance reading from S3 through an instance role; a GitHub Actions job deploying via OIDC-assumed role (no stored
keys); cross-account access; read-only auditor access; a developer group limited to a dev environment.
