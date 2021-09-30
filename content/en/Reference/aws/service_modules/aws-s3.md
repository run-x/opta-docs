---
title: "aws-s3"
linkTitle: "aws-s3"
date: 2021-07-21
draft: false
weight: 1
description: Creates an S3 bucket for storage purposes
---

This module creates an S3 bucket for storage purposes. It is created with server-side AES256 encryption.


### Example

```
  - name: bucky
    type: aws-s3
    bucket_name: dev-runx-bucky
    cors_rule:
      allowed_methods:
        - "PUT"
      max_age_seconds: 3600
      allowed_origins:
        - "runx.dev"
```


### Linking

When linked to a k8s-service or IAM role/user, this adds the necessary IAM permissions to read
(e.g. list objects and get objects) and/or write (e.g. list, get,
create, destroy, and update objects) to the given s3 bucket.
The current permissions are, "read" and "write", defaulting to "write" if none specified


## Fields


| Name      | Description | Default | Required |
| ----------- | ----------- | ------- | -------- |
| `bucket_name` | The name of the bucket to create. | `None` | True |
| `same_region_replication` | Create a same-region bucket for replica storage (needed for compliance). Can be added later without destroying the resource. | `False` | False |
| `block_public` | Block all public access. | `True` | False |
| `bucket_policy` | A custom s3 policy json/yaml to add. | `None` | False |
| `cors_rule` | A custom cors policy. | `None` | False |

## Outputs


| Name      | Description |
| ----------- | ----------- |
| `bucket_id` | The id of the S3 bucket |
| `bucket_arn` | The arn of the S3 bucket |