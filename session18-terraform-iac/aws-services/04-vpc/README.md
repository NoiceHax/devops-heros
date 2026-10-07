# VPC: Virtual Private Cloud (Networking)

**What it is:** your own logically isolated network inside AWS. You pick the IP range, split it into subnets, and control
routing and firewalls. EC2, RDS, load balancers etc. all live inside a VPC.

| Concept | Meaning |
|---|---|
| **CIDR** | The IP range, e.g. `10.0.0.0/16` = 65,536 addresses (`/16` means the first 16 bits are the network). Subnets carve it up: `10.0.1.0/24` = 256 addresses (5 are reserved by AWS). Ranges must not overlap if you ever peer VPCs. |
| **Subnet** | A slice of the VPC CIDR inside **one Availability Zone** |
| **Route table** | Rules mapping destination CIDRs to targets (`local`, an IGW, a NAT gateway...). Each subnet uses one. |
| **Internet Gateway (IGW)** | Lets a VPC reach and be reached from the internet (two-way) |
| **NAT Gateway** | Lets **private** instances start outbound connections (patches, APIs) without being reachable from outside. Lives in a public subnet; billed hourly plus per GB. |
| **Security Group** | Stateful firewall on a network interface; allow rules only |
| **Network ACL** | **Stateless** firewall on a subnet; allow and deny rules, evaluated in order; return traffic must be allowed explicitly |

## Public vs private subnet

A subnet is **public** if its route table has `0.0.0.0/0 → Internet Gateway` (and instances have public IPs). It is **private**
if not; private subnets reach the internet, if at all, via `0.0.0.0/0 → NAT Gateway`.

```
Internet ── IGW ── public subnet (10.0.1.0/24):  web/ALB, NAT GW
                         │
                   private subnet (10.0.2.0/24): app, database  (no inbound path from the internet)
```

## Hands-on (LocalStack, `transcripts/s18/11-aws-services-cli.txt`)

Created a `10.0.0.0/16` VPC, a public (`10.0.1.0/24`, AZ a) and a private (`10.0.2.0/24`, AZ b) subnet, an Internet Gateway,
a route table with `0.0.0.0/0 → igw-…` associated **only** with the public subnet, and a security group allowing TCP 443.
`describe-route-tables` printed `10.0.0.0/16 local` and `0.0.0.0/0 igw-…`: that default route is what makes the subnet public.

The same network built in Terraform is session 19.

## Good practice

Databases and app servers in private subnets; only load balancers and bastions in public ones; spread subnets over at
least two AZs; use security groups as the main control and NACLs as a coarse extra layer.
