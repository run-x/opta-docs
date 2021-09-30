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


| Name      | Description | Default | Required |
| ----------- | ----------- | ------- | -------- |
| `fifo` | FIFO queue or not | `False` | False |
| `content_based_deduplication` | FIFO queue or not | `False` | False |
| `delay_seconds` | Seconds to delay passing the message forward | `0` | False |
| `message_retention_seconds` | The number of seconds SQS retains a message. | `345600` | False |
| `receive_wait_time_seconds` | The seconds for which a ReceiveMessage call will wait for a message to arrive (long polling) before returning. Must be an int from 0-20. | `0` | False |

## Outputs


| Name      | Description |
| ----------- | ----------- |
| `queue_arn` | Arn of the queue jsut created |
| `queue_name` | Name of the queue jsut created |
| `queue_id` | ID of the queue jsut created |