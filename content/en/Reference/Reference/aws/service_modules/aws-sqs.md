---
title: "aws-sqs"
linkTitle: "aws-sqs"
date: 2021-07-21
draft: false
weight: 1
description: Sets up a AWS SQS queue
---

### Linking

When linked to a k8s-service or IAM role/user, this adds the necessary IAM permissions to publish
(e.g. put new messages) and/or subscribe (e.g. read/remove messages) to the given queue.
The current permissions are, "publish" and "subscribe", defaulting to \["publish", "subscribe",] if none specified.
Link also grants encrypt/decrypt permission for the queue's KMS key.


## Fields

- `fifo` - Optional. FIFO queue or not Default False
- `content_based_deduplication` - Optional. FIFO queue or not Default False
- `delay_seconds` - Optional. Seconds to delay passing the message forward Default 0
- `message_retention_seconds` - Optional. The number of seconds SQS retains a message. Default 345600
- `receive_wait_time_seconds` - Optional. The seconds for which a ReceiveMessage call will wait for a message to arrive (long polling) before returning. Must be an int from 0-20. Default 0

## Outputs

- queue_arn - Arn of the queue jsut created
- queue_name - Name of the queue jsut created
- queue_id - ID of the queue jsut created