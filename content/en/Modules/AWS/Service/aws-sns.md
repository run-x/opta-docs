---
title: "aws-sns"
linkTitle: "aws-sns"
date: 2021-07-21
draft: false
weight: 1
description: Sets up a AWS SNS topic
---

Sets up a AWS SNS topic.

### Fields

- `fifo` -- Optional. FIFO queue or not. Default = false
- `content_based_deduplication` -- Optional. Default = false
- `sqs_subscribers` -- Optional. List of SQS ARNs.

### Outputs

- `topic_arn` -- ARN for the topic

### Linking

When linked to a k8s-service or IAM role/user, this adds the necessary IAM permissions to publish
notifications to the topic. The current permission allowed is just, "publish".
Link also grants encrypt/decrypt permission for the topic's KMS key.
