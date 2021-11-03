---
title: "dynamodb-table"
linkTitle: "dynamodb-table"
date: 2021-07-21
draft: false
weight: 1
description: Creates a dynamodb table to use
---

This module creates a dynamodb table as per the specifications in the input.

### Linking

When linked to a k8s-service or IAM role/user, this adds the necessary IAM permissions to publish
notifications to the topic. The current permissions allowed are "read" and "write" (defaults to "write).
Link also grants encrypt/decrypt permission for the table's KMS key.

## Fields


| Name      | Description | Default | Required |
| ----------- | ----------- | ------- | -------- |
| `read_capacity` | This is the read capacaity for your dynamodb table | `20` | False |
| `write_capacity` | This is the write capacaity for your dynamodb table | `20` | False |
| `billing_mode` | The billing mode for you dynamodb table | `PROVISIONED` | False |
| `hash_key` | The hash key for your table | `` | True |
| `range_key` | The range key for your table | `None` | False |
| `attributes` | The list of attributes (name and type) for this dynamodb table | `None` | True |

## Outputs


| Name      | Description |
| ----------- | ----------- |
| `table_arn` | The arn of the table |
| `table_id` | The id of the table |
| `kms_arn` | The arn of the table's kms encryption key |
| `kms_id` | The id of the table's kms encryption key |