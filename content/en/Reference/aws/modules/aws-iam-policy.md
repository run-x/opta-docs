---
title: "aws-iam-policy"
linkTitle: "aws-iam-policy"
date: 2022-06-08
draft: false
weight: 1
description: Creates an IAM policy
---

This module can be used to create and manage an AWS IAM policy via opta

### Example
```yaml
  - name: policy
    type: aws-iam-policy
    file: valid_policy.json
```

Note: A valid policy document would look something like this.
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ec2:Describe*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
```


## Fields


| Name      | Description | Default | Required |
| ----------- | ----------- | ------- | -------- |
| `file` | Json file path containing the Policy | `` | True |

## Outputs


| Name      | Description |
| ----------- | ----------- |
| `policy_arn` | The arn of the IAM policy |
| `policy_id` | The id of the IAM policy |
| `policy_name` | The name of the IAM policy |