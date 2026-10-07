# DynamoDB & RDS: Database Services

## DynamoDB (NoSQL, serverless)

| Concept | Meaning |
|---|---|
| **NoSQL** | No fixed schema or joins; data is modelled around access patterns |
| **Table** | A collection of items; no servers to manage |
| **Item** | One record (up to 400 KB) |
| **Attribute** | A field. Only the key attributes are required; other items can have different attributes. |
| **Partition key** | Required. Hashed to decide the physical partition; must spread load evenly (a "hot key" throttles) |
| **Sort key** | Optional. Orders items within one partition key and enables range queries (`>=`, `begins_with`, `between`) |

Hands-on (`transcripts/s18/11-aws-services-cli.txt`): table `Orders` with partition key `customer_id` and sort key `order_date`,
`PAY_PER_REQUEST` billing. Two items for customer `c1` had *different attributes* (one has `coupon`, one has `items`), and a
`query` with `customer_id = :c AND order_date >= :d` returned only the later order. `query` is cheap because it uses the
key; `scan` reads the whole table.

**Use cases:** sessions and shopping carts, IoT/event data, leaderboards, anything needing single-digit-millisecond reads at any scale.
Avoid for ad-hoc analytics and complex relationships.

## RDS (managed relational)

| Concept | Meaning |
|---|---|
| **Relational** | Tables, SQL, joins, transactions (ACID), fixed schema |
| **Supported engines** | PostgreSQL, MySQL, MariaDB, Oracle, SQL Server, Db2, and Amazon Aurora (MySQL/PostgreSQL compatible, cloud-native) |
| **DB instance** | The managed server: you choose engine, instance class and storage. AWS handles OS, patching, backups and failover; you cannot SSH in. |
| **Security** | Run in **private subnets**, restrict the security group to the app tier only, encrypt at rest (KMS) and in transit (TLS), IAM auth and Secrets Manager for credentials, no public access |
| **Backups** | Automated daily snapshots + transaction logs (point-in-time restore, 1 to 35 days) and manual snapshots |
| **Multi-AZ** | A **synchronous standby** in another AZ for **high availability**: automatic failover; the standby does not serve reads |
| **Read replicas** | **Asynchronous** copies for **read scaling** (and cross-region DR); can be promoted; slight replication lag |

Multi-AZ answers "what if an AZ dies?", read replicas answer "what if reads are too heavy?". They solve different problems and are often combined.

RDS is not available in LocalStack's free edition, so there is no CLI demo here; the content above is documentation.

**Use cases:** the system of record for web apps (orders, users, billing), anything needing joins and transactions.

## Choosing

| Need | Pick |
|---|---|
| Relationships, SQL, transactions, reporting | RDS |
| Massive scale, key-based access, flexible items, no ops | DynamoDB |
