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

- `allowed_k8s_services` - Optional. K8s service accounts that this role should have access to. Default []
- `allowed_iams` - Optional. The arns of IAM users/roles allowed to assume this role. Default []
- `extra_iam_policies` - Optional. The arns of additional IAM policies to be attached to this role. Default []
- `links` - Optional. The list of links to add permissions for to this role. Default []

## Outputs

- role_arn - The arn of the role just created