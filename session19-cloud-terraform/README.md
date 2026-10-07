# Session 19: Cloud & Terraform in Action

An end-to-end AWS network + server + bucket, defined entirely in Terraform. It was applied and destroyed against
**LocalStack 4.9.2** (a local AWS emulator), so no real AWS account or cost was involved. Output is in
[`../transcripts/s19/`](../transcripts/s19/). Switching to real AWS needs one variable (see the end).

## Architecture

```
                         Internet
                            │
                    ┌───────┴────────┐
                    │ Internet       │  aws_internet_gateway.main
                    │ Gateway        │
                    └───────┬────────┘
   ┌────────────────────────┼─────────────────────────────────┐
   │ VPC 10.20.0.0/16       │            aws_vpc.main         │
   │                ┌───────┴────────┐                        │
   │                │ Route table    │  0.0.0.0/0 → IGW       │
   │                └───────┬────────┘  (aws_route_table.public + association)
   │   ┌────────────────────┴───────────────────────┐        │
   │   │ Public subnet 10.20.1.0/24 (ap-south-1a)   │        │
   │   │   ┌────────────────────────────────────┐   │        │
   │   │   │ EC2 t3.micro   aws_instance.web    │   │        │
   │   │   │ Security group: 80, 443 in; all out│   │        │
   │   │   └────────────────────────────────────┘   │        │
   │   └────────────────────────────────────────────┘        │
   └──────────────────────────────────────────────────────────┘

        S3 bucket (versioned, public access blocked)   ← regional service, lives outside the VPC
```

| File | Purpose |
|---|---|
| `versions.tf` | Required Terraform and provider versions (`aws ~> 6.0`) |
| `provider.tf` | AWS provider; the `use_localstack` switch redirects the endpoints to LocalStack |
| `variables.tf` | Inputs: region, CIDRs, AMI, instance type, bucket name |
| `main.tf` | The 10 resources |
| `outputs.tf` | VPC, subnet, security group, instance IDs, private IP, bucket name |
| `localstack.tfvars` / `terraform.tfvars.example` | Values for LocalStack / template for real AWS |

## Concepts demonstrated

**Providers**: `hashicorp/aws` is a plugin that translates resources into AWS API calls. `provider.tf` configures it;
`terraform init` downloads it and records the exact version in `.terraform.lock.hcl`.

**Variables and locals**: everything environment-specific (`ami_id`, `bucket_name`, `use_localstack`) is a variable, with
`terraform.tfvars` or `-var-file` supplying values. `local.common_tags` is defined once and merged into every resource.

**Resources**: 10 in total: VPC, subnet, internet gateway, route table + association, security group, EC2 instance, and the S3
bucket with its versioning and public-access-block settings (separate resources in provider v4+).

**Dependencies**: Terraform builds a graph from references and creates things in the right order, in parallel where it can.
`terraform graph` printed these edges (full output in `01-apply.txt`):

```
aws_instance.web  → aws_subnet.public, aws_security_group.web, aws_internet_gateway.main
aws_subnet.public → aws_vpc.main        aws_route_table.public → aws_internet_gateway.main
```

- *Implicit*: `vpc_id = aws_vpc.main.id` makes the subnet wait for the VPC.
- *Explicit*: `depends_on = [aws_internet_gateway.main]` on the instance, because nothing in its arguments references the IGW
  but a public instance needs the internet route to exist.
- The S3 bucket has no edges to the network, so it was created *in parallel* with the VPC (visible in the apply log).

**State**: `terraform.tfstate` maps each resource in the code to a real object ID. `terraform state list` showed all 10
and `terraform state show aws_vpc.main` its recorded attributes. State is how Terraform knows what to change or destroy,
so it is git-ignored (it can contain secrets) and, in a team, belongs in a remote backend with locking.

**Workflow** (`01-apply.txt`, `02-verify-update-destroy.txt`):

| Command | Result |
|---|---|
| `terraform fmt -check`, `validate` | clean / "configuration is valid" |
| `terraform plan -out=tfplan` | `Plan: 10 to add, 0 to change, 0 to destroy` |
| `terraform apply tfplan` | 10 resources created (applies exactly the reviewed plan) |
| AWS CLI checks | VPC `10.20.0.0/16`, instance `running` at `10.20.1.4`, SG ports 80/443, bucket versioning `Enabled` |
| Add a tag to `local.common_tags`, `plan` | 7 resources updated **in place**, nothing replaced |
| `terraform destroy` | 10 destroyed, state empty, nothing left in LocalStack |

## Something worth knowing: the "1 to change" plan

Right after the first apply, a second `plan` reported one change: the S3 bucket's tags. LocalStack drops bucket tags when
the versioning and public-access-block resources are created straight after the bucket. Real AWS does not. A further apply
restored the tags and the next plan said `No changes`. The lesson: a plan after an apply is a useful drift check, and a
non-empty one means *investigate*, not necessarily *you made a mistake*. Here the cause was the emulator.

## Using real AWS instead

```bash
cp terraform.tfvars.example terraform.tfvars    # set ami_id (Amazon Linux 2023 for your region) and a unique bucket_name
terraform init && terraform plan && terraform apply
terraform destroy                                # always, to avoid charges
```

`use_localstack` defaults to `false`, so the same code runs against real AWS with your normal credentials.
