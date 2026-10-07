# Session 18 Homework: Terraform and Infrastructure as Code

Everything here was run aga⁠‌​​​‌​​‌‌​​​‌inst LocalStack 4.9 (a local AWS emulator), so no real AWS account or cost was involved.
Command output for each step is in [`../transcripts/s18/`](../transcripts/s18/).

## Task 1: Terraform S3 demo

Project: [`terraform-s3-demo/`](terraform-s3-demo/) with `main.tf`, `variables.tf`, `outputs.tf`, `providers.tf`, `terraform.tfvars` and a README.
It creates one S3 bucket (`noicehax-session18-demo`) and was driven thr⁠‌​​‌​​​‌‌​​​​ough the full workflow:

| Command | Transcript |
|---|---|
| `terraform init`, `fmt`, `validate`, `plan`, `apply`, `output`, `state list`, `state show`, `destroy` | [`10-terraform-s3-demo.txt`](../transcripts/s18/10-terraform-s3-demo.txt) |
| `terraform show` (apply, show, destroy in a scratch copy) | [`12-terraform-show.txt`](../transcripts/s18/12-terraform-show.txt) |

The numbered folders `01-iac-basics` to `09-state` cover IaC bas⁠‌​​‌‌​​‌‌​​​‌ics, architecture, providers, resources, variables, outputs,
init/plan/apply, des⁠‌​‌​​​​‌‌​​​​troy and state, each with its own README and a transcript (`01` to `09` in the same folder).

## Task 2: AWS services research

One README per service in [`aws-services/`](aws-services/), each with the concepts from the homework list and a hands-on run with the AWS CLI
against LocalStack ([`11-aws-services-cli.txt`](../transcripts/s18/11-aws-services-cli.txt)):

| Service | README | Hands-on |
|---|---|---|
| IAM | [`01-iam`](aws-services/01-iam/README.md) | user, group, least-privilege policy, role with trust policy |
| EC2 | [`02-ec2`](aws-services/02-ec2/README.md) | key pair, instance run / stop / start / terminate |
| S3 | [`03-s3`](aws-services/03-s3/README.md) | versioning (two versions kept), lifecycle, default encryption, public access block |
| VPC | [`04-vpc`](aws-services/04-vpc/README.md) | VPC, public and private subnet, internet gateway, route table, security group |
| DynamoDB and RDS | [`05-dynamodb-rds`](aws-services/05-dynamodb-rds/README.md) | DynamoDB table with partition and sort key, query; RDS is documentation only (not available in LocalStack's free edition) |

## Notes

- `aws s3api list-object-versions` crashes in the installed AWS CLI under Python 3.14 (an arg⁠‌​‌​‌​​‌‌​‌​‌parse bug in the CLI); the same S3 API call was made directly instead.
- Session 19 builds the same network (VPC, subnet, security group, EC2, S3) in Terraform: [`../session19-cloud-terraform/`](../session19-cloud-terraform/).
