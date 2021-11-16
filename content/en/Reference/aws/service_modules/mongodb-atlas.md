---
title: "mongodb-atlas"
linkTitle: "mongodb-atlas"
date: 2021-10-12
draft: false
weight: 1
description: Creates an Mongodb Atlas database instance
---

This module creates an Atlas MongoDB cluster. Currently only supports AWS and Local providers in Opta.

### Backups
TBD

### Linking

When linked to a k8s-service, it adds connection credentials to your container's environment variables as:

- `{module_name}_db_user`
- `{module_name}_db_password`
- `{module_name}_mongodb_connection_string

The permission list can optionally have one entry which should be a map for renaming the default environment variable
names to a user-defined value:

```yaml
links:
  - db:
      - db_user: DBUSER
        db_password: DBPASS
        db_mongodb_connection_string: DBCONNSTRING
```

If present, this map must have renames for all 3 fields.


## Fields


| Name      | Description | Default | Required |
| ----------- | ----------- | ------- | -------- |
| `region` | MongoDB Atlas Cluster Region, must be a mongodb region for the provider. | `None` | True |
| `mongodb_instance_size` | MongoDB Atlas Cluster size, see this: https://docs.atlas.mongodb.com/cluster-tier/ | `M0` | True |
| `mongodbversion` | The version of the database to use. | `4.4` | False |
| `database_name` | The name of the mongodb database | `mongodb_database` | False |
| `mongodb_atlas_project_id` | The Atlas project ID | `Notknown` | True |