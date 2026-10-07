# S3: Simple Storage Service (Storage)

**What it is:** object sto⁠‌​​‌​​​‌‌​​​​rage with practically unlimited capacity, 11 nines of durability, accessed over HTTPS. It is not a
filesystem or a block device: you store and fetch whole obj⁠‌​​‌‌​​‌‌​​​‌ects by key.

| Concept | Meaning |
|---|---|
| **Bucket** | Top-level container. Name is **globally unique**; lives in one region. |
| **Object** | Data + metadata, addressed by **key** (`logs/2026/app.log`). "Folders" are just key prefixes. Up to 5 TB each. |
| **Storage classes** | Cost vs access trade-off: Standard, Intelligent-Tiering, Standard-IA, One Zone-IA, Glacier Instant / Flexible / Deep Archive |
| **Versioning** | Keeps every version of a key; deleting adds a *delete marker*. Protects against overwrites and accidental deletes. |
| **Lifecycle policy** | Rules that move objects to cheaper classes or expire them after N days |
| **Encryption** | Server-side encryption is on by default (SSE-S3); optionally SSE-KMS for key control and audit; TLS in transit |
| **Bucket policy** | Resource-based JSON policy on the bucket (who may access it, from where, over TLS only...) |

## Hands-on (LocalStack, `transcripts/s18/11-aws-services-cli.txt`)

```bash
awslocal s3 mb s3://demo-bucket-18
awslocal s3api put-bucket-versioning --bucket demo-bucket-18 --versioning-configuration Status=Enabled
awslocal s3 cp f.txt s3://demo-bucket-18/f.txt                  # uploaded twice with different content
awslocal s3api put-bucket-lifecycle-configuration ...           # logs/: to STANDARD_IA at 30 days, expire at 365
awslocal s3api put-bucket-encryption ...                        # default SSE AES256
awslocal s3api put-public-access-block ...                      # block all public access
```

Result: **two versions of `f.txt` were kept** (the latest plus the original); the lifecycle rule and default enc⁠‌​‌​​​​‌‌​​​​ryption
were stored and read back.

The Terraform equivalent (creating the buc⁠‌​‌​‌​​‌‌​‌​‌ket) is `terraform-s3-demo/` in this repo.

## Common use cases

Static website/asset hos⁠​​​​​​‌​​​​‌‌ting, backups and archives, data lakes, log collection, build artifacts, Terraform remote state
(with versioning and locking). Keep buckets private by def⁠​​​​‌​‌‌​‌​​​ault (Block Public Access) and serve public content through
CloudFront.
