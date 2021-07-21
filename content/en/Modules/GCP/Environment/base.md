---
title: "base"
linkTitle: "base"
date: 2021-07-21
draft: false
weight: 1
description: Sets up VPC, private subnet, firewall, default kms key, and private service access. Also activates the container registry
---

This module is the "base" module for creating an environment in gcp. It sets up the VPC, private subnet, firewall,
default kms key, private service access, and activate the container registry. Defaults are set to work 99% of the time, assuming no funny
networking constraints (you'll know them if you have them), so _no need to set any of the fields or know what the outputs do_.

### Fields

- `private_ipv4_cidr_block` -- Optional. This is the cidr block for VM instances in the VPC. Defaults to "10.0.0.0/19"
- `cluster_ipv4_cidr_block` -- Optional. This is the cidr block reserved for pod ips in the GKE cluster. Defaults to "10.0.32.0/19"
- `services_ipv4_cidr_block` -- Optional This is the cidr block reserved for service cluster ips in the GKE cluster. Defaults to "10.0.64.0/20"

### Outputs

- `kms_account_key_id` -- The id of the [KMS](https://cloud.google.com/security-key-management) key (this is what handles
  encryption for redis, gke, etc...)
- `kms_account_key_self_link` -- The self link of the default
  KMS key (sometimes things need the ID, sometimes the ARN, so we're giving both)
- `vpc_id` -- The ID of the [VPC](https://cloud.google.com/vpc/docs/vpc) we created for this environment
- `private_subnet_id` -- The ID of the private [subnets](https://cloud.google.com/vpc/docs/vpc#subnet-ranges)
  we setup for your environment
