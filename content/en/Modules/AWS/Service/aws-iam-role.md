---
title: "aws-iam-role"
linkTitle: "aws-iam-role"
date: 2021-07-21
draft: false
weight: 1
description: Creates an IAM role
---

### Fields

- `allowed_k8s_services` -- Optional. K8s service accounts that this role should have
  access to.
- `allowed_iams` -- Optional. IAM users/roles allowed to assume this role
- `extra_iam_policies` -- Optional. Additional IAM policies to be attached to this role.

### Outputs

- `role_arn` -- The ARN for this role

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
