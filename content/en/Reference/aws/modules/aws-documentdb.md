---
title: "aws-documentdb"
linkTitle: "aws-documentdb"
date: 2021-07-21
draft: false
weight: 1
description: Creates an AWS Documentdb cluster
---

This module creates an AWS Documentdb cluster. It is made in the private subnets automatically created for the environment.
macro and so can only be accessed in the VPC or through some proxy (e.g. VPN). It is encrypted
at rest with a kms key created in the env setup and in transit via tls.

### Linking

When linked to a k8s-service, this adds connection credentials to your container's environment variables as:

- `{module_name}_db_user`
- `{module_name}_db_password`
- `{module_name}_db_host`

The permission list can optionally have one entry which should be a map for renaming the default environment variable
names to a user-defined value:

```yaml
links:
  - db:
      - db_user: DBUSER
        db_host: DBHOST
        db_password: DBPASS
```

If present, this map must have renames for all 3 fields.

In addition to these credentials, you also need to enable SSL encryption when
connecting ([AWS docs](https://docs.aws.amazon.com/documentdb/latest/developerguide/connect_programmatically.html)).
Fortunately, the Opta k8s-service module has already taken care of that. On linking, you'll
find the AWS CA at `/config/rds_ca.pem`

As an example, this is how the mongoose/node connection looks like:

```
await mongoose.connect("mongodb://<USER>:<PASSWORD>@<HOST>, {
  ssl: true,
  sslCA: require('fs').readFileSync(`/config/rds_ca.pem`)
});
```

## Fields


| Name      | Description | Default | Required |
| ----------- | ----------- | ------- | -------- |
| `engine_version` | The version of mongodb to use | `4.0.0` | False |
| `instance_class` | This is the RDS instance type used for the documentdb cluster [instances](https://aws.amazon.com/documentdb/pricing/). | `db.r5.large` | False |
| `instance_count` | This is to specify the count of instances for Document DB Cluster. Note -> These would be Multi-AZ. | `1` | False |
| `deletion_protection` | A value that indicates whether the DB cluster has deletion protection enabled. The database can't be deleted when deletion protection is enabled. By default, deletion protection is disabled. | `False` | False |

## Outputs


| Name      | Description |
| ----------- | ----------- |
| `db_host` | The host of the database. |
| `db_user` | The user of the database. |