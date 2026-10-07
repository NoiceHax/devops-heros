# EC2: Elastic Compute Cloud (Compute)

**What it is:** resizable virtual machines in AWS. You choose the OS image, CPU/RAM, storage and network, and pay per
second while the instance runs.

| Concept | Meaning |
|---|---|
| **AMI** | Amazon Machine Image: the template (OS + preinstalled software) an instance boots from. Region-specific. |
| **Instance type** | Hardware shape, named `family.size`: `t3.micro` (burstable, general), `m5` (balanced), `c5` (compute), `r5` (memory), `g5` (GPU) |
| **Key pair** | Public key stored on the instance, private key kept by you; used for SSH (Linux) or password decryption (Windows) |
| **Security group** | A **stateful** virtual firewall on the instance's network interface. Allow rules only; return traffic is automatic. |
| **EBS** | Network-attached block storage volumes (root disk plus extra). Persist independently of the instance; snapshots go to S3. *Instance store* is local and lost on stop. |
| **Public vs private IP** | Private IP is fixed for the instance's life inside the VPC. A public IP is optional and **changes on stop/start**; an *Elastic IP* is a static public IP you own. |

## Instance lifecycle

```
pending ─► running ─► stopping ─► stopped ─► pending ─► running
              └──────► shutting-down ─► terminated   (cannot be restarted)
```

Stopped instances do not bill for compute but their EBS volumes still bill. Terminating deletes the instance (and the root
volume by default).

## Hands-on (LocalStack, `transcripts/s18/11-aws-services-cli.txt`)

```bash
awslocal ec2 create-key-pair --key-name demo-key
awslocal ec2 run-instances --image-id <ami> --instance-type t3.micro --key-name demo-key \
        --subnet-id <public-subnet> --security-group-ids <sg>
awslocal ec2 describe-instances ...     # running, 10.0.1.4 (a private IP from the subnet's CIDR)
awslocal ec2 stop-instances / start-instances / terminate-instances
```

The run showed the state transitions `running → stopping`, `pending` (restart) and `shutting-down` (terminate).
LocalStack only emulates the API; it does not boot a real OS.

## Common use cases

Web/app servers behind a load balancer, batch and CI workers, self-managed databases, anything needing a full OS.
Prefer Auto Scaling groups plus a launch template over hand-managed single instances; use Spot for fault-tolerant work.
In Terraform this is `aws_instance` (session 19).
