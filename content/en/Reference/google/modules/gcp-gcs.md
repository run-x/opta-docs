---
title: "gcp-gcs"
linkTitle: "gcp-gcs"
date: 2021-07-21
draft: false
weight: 1
description: Creates a GCS bucket for storage purposes
---

This module creates a GCS bucket for storage purposes. It is created with encryption based on the default kms key
created for you in the base, as well as the standard AES-256 encryption.

### Linking

When linked to a gcp-k8s-service, this adds the necessary IAM permissions to read
(e.g. list objects and get objects) and/or write (e.g. list, get,
create, destroy, and update objects) to the given gcs bucket.
The current permissions are, "read" and "write". These need to be
specified when you add the link.


## Fields


| Name      | Description | Default | Required |
| ----------- | ----------- | ------- | -------- |
| `bucket_name` | The name of the bucket to create. | `None` | True |
| `block_public` | Block all public access. | `True` | False |

## Outputs


| Name      | Description |
| ----------- | ----------- |
| `bucket_id` | The id of the bucket. |
| `bucket_name` | The name of the bucket. |