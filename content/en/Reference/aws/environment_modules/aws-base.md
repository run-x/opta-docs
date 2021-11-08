---
title: "base"
linkTitle: "base"
date: 2021-07-21
draft: false
weight: 1
description: Sets up VPCs, a default KMS key, and the db/cache subnets for your environment
---

The defaults for this module are set to work 99% of the time, assuming no funny networking constraints (you'll know them
if you have them), so in most cases, there is _no need to set any of the fields or know what the outputs do_.


## Fields


| Name      | Description | Default | Required |
| ----------- | ----------- | ------- | -------- |
| `total_ipv4_cidr_block` | This is the total cidr block for the VPC. | `10.0.0.0/16` | False |
| `private_ipv4_cidr_blocks` | These are the cidr blocks to use for the private subnets, one for each AZ. | `['10.0.128.0/21', '10.0.136.0/21', '10.0.144.0/21']` | False |
| `public_ipv4_cidr_blocks` | These are the cidr blocks to use for the public subnets, one for each AZ. | `['10.0.0.0/21', '10.0.8.0/21', '10.0.16.0/21']` | False |

## Outputs


| Name      | Description |
| ----------- | ----------- |
| `kms_account_key_arn` | The [ARN](https://docs.aws.amazon.com/general/latest/gr/aws-arns-and-namespaces.html) of the default [KMS](https://aws.amazon.com/kms/) key (this is what handles encryption for redis, documentdb, eks, etc…) |
| `kms_account_key_id` | The [ID](https://docs.aws.amazon.com/kms/latest/developerguide/find-cmk-id-arn.html) of the default KMS key (sometimes things need the ID, sometimes the ARN, so we’re giving both) |
| `vpc_id` | The ID of the [VPC](https://docs.aws.amazon.com/vpc/latest/userguide/what-is-amazon-vpc.html) we created for this environment |
| `private_subnet_ids` | The IDs of the private [subnets](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Subnets.html) we setup for your environment |
| `public_subnets_ids` | The IDs of the public [subnets](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Subnets.html) we setup for your environment |
| `s3_log_bucket_name` | The name of the default logging bucket provisioned by opta |
| `public_nat_ips` | Public static IP of nat gateway(s) |