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

### Fields

- `instance_class` -- Optional. This is the RDS instance type used for the Aurora cluster [instances](https://aws.amazon.com/rds/instance-types/).
  Default db.r5.large
- `engine_version` -- Optional. The version of the database to use. Default 11.9.

### Linking

When linked to a k8s-service, it adds connection credentials to your container's environment variables as:

- `{module_name}_db_user`
- `{module_name}_db_password`
- `{module_name}_db_name`
- `{module_name}_db_host`

In the [modules reference](/modules-reference) example, the _{module_name}_ would be replaced with `rds`

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
