---
title: "postgres"
linkTitle: "postgres"
date: 2021-07-21
draft: false
weight: 1
description: Creates a postgres Aurora RDS database instance
---

This module creates a postgres Aurora RDS database instance. It is made in the
private subnets automatically created during environment setup and so can only be accessed in the
VPC or through some proxy (e.g. VPN).

### Backups
Opta will provision your database with 7 days of automatic daily backups in the form of 
[RDS snapshots](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_CreateSnapshot.html). 
You can find them either programmatically via the aws cli, or through the AWS web console (they will be called
system snapshots, and they have a different tab than the manual ones).

### Linking

When linked to a k8s-service, it adds connection credentials to your container's environment variables as:

- `{module_name}_db_user`
- `{module_name}_db_password`
- `{module_name}_db_name`
- `{module_name}_db_host`

In the [modules reference](/reference) example, the _{module_name}_ would be replaced with `rds`

The permission list can optionally have one entry which should be a map for renaming the default environment variable
names to a user-defined value:

```yaml
links:
  - db:
      - db_user: DBUSER
        db_host: DBHOST
        db_name: DBNAME
        db_password: DBPASS
```

If present, this map must have renames for all 4 fields.


## Fields

- `instance_class` - Optional. This is the RDS instance type used for the Aurora cluster [instances](https://aws.amazon.com/rds/instance-types/). Default db.t3.medium
- `engine_version` - Optional. The version of the database to use. Default 11.9
- `multi_az` - Optional. Enable read-write replication across different availability zones on the same reason (doubles the cost, but needed for compliance). Can be added and updated at a later date without need to recreate. Default False
- `safety` - Optional. Add deletion protection to stop accidental db deletions Default False

## Outputs

