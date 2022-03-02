---
title: "aws-sns"
linkTitle: "aws-sns"
date: 2021-07-21
draft: false
weight: 1
description: Sets up an AWS SNS topic
---

Sets up an AWS SNS topic.

### Linking

When linked to a k8s-service or IAM role/user, this adds the necessary IAM permissions to publish
notifications to the topic. The current permission allowed is just, "publish".
Link also grants encrypt/decrypt permission for the topic's KMS key.


## Fields


| Name      | Description | Default | Required |
| ----------- | ----------- | ------- | -------- |
| `fifo` | FIFO queue or not. | `False` | False |
| `content_based_deduplication` | Duplicate content | `False` | False |
| `sqs_subscribers` | List of SQS ARNs to push from this topic. | `[]` | False |

## Outputs


| Name      | Description |
| ----------- | ----------- |
| `topic_arn` | Arn of the topic just created |