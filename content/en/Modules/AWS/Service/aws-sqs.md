---
title: "aws-sqs"
linkTitle: "aws-sqs"
date: 2021-07-21
draft: false
weight: 1
description: Sets up a AWS SQS queue
---

### Fields

- `fifo` -- Optional. FIFO queue or not. Default = false
- `content_based_deduplication` -- Optional. Default = false
- `delay_seconds` -- Optional. Default = 0
- `message_retention_seconds` -- Optional. Default = 345600 (4 days)
- `receive_wait_time_seconds` -- Optional. Default = 0

### Outputs

- `queue_arn` -- ARN for the Queue
- `queue_id` -- ID of the Queue
- `queue_name` -- Name of the Queue

### Linking

When linked to a k8s-service or IAM role/user, this adds the necessary IAM permissions to publish
(e.g. put new messages) and/or subscribe (e.g. read/remove messages) to the given queue.
The current permissions are, "publish" and "subscribe", defaulting to \["publish", "subscribe",] if none specified.
Link also grants encrypt/decrypt permission for the queue's KMS key.
