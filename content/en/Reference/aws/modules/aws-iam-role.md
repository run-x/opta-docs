---
title: "aws-iam-role"
linkTitle: "aws-iam-role"
date: 2021-07-21
draft: false
weight: 1
description: Creates an IAM role
---

This module can be used to create and manage an AWS IAM role via opta

### Linking

This module can also be linked to other resource - which will provide it
permission to access them.

### Example

```
  - name: deployer
    type: aws-iam-role
    extra_iam_policies:
      - "arn:aws:iam::aws:policy/CloudWatchEventsFullAccess"
    allowed_k8s_services:
      - namespace: "*"
        service_name: "*"
```

## Fields


| Name      | Description | Default | Required |
| ----------- | ----------- | ------- | -------- |
| `allowed_k8s_services` | K8s service accounts that this role should have access to. | `[]` | False |
| `allowed_iams` | The arns of IAM users/roles allowed to assume this role. | `[]` | False |
| `extra_iam_policies` | The arns of additional IAM policies to be attached to this role. | `[]` | False |
| `links` | The list of links to add permissions for to this role. | `[]` | False |

## Outputs


| Name      | Description |
| ----------- | ----------- |
| `role_arn` | The arn of the role just created |