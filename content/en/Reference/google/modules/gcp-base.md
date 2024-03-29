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


## Fields


| Name      | Description | Default | Required |
| ----------- | ----------- | ------- | -------- |
| `private_ipv4_cidr_block` | Cidr block for private subnet. Don't need to worry about AZs in GCP | `10.0.0.0/19` | False |
| `cluster_ipv4_cidr_block` | This is the cidr block reserved for pod ips in the GKE cluster. | `10.0.32.0/19` | False |
| `services_ipv4_cidr_block` | This is the cidr block reserved for service cluster ips in the GKE cluster. | `10.0.64.0/20` | False |
| `k8s_master_ipv4_cidr_block` | This is the cidr block reserved for the master/control plane in the GKE cluster. | `10.0.80.0/28` | False |

## Outputs


| Name      | Description |
| ----------- | ----------- |
| `kms_account_key_id` | The id of the [KMS](https://cloud.google.com/security-key-management) key (this is what handles encryption for redis, gke, etc...) |
| `vpc_id` | The ID of the [VPC](https://cloud.google.com/vpc/docs/vpc) we created for this environment |
| `vpc_self_link` | str |
| `private_subnet_id` | The ID of the private [subnet](https://cloud.google.com/vpc/docs/vpc#subnet-ranges) we setup for your environment |
| `private_subnet_self_link` | Self lin to the private subnet |
| `k8s_master_ipv4_cidr_block` | This is the cidr block reserved for the master/control plane in the GKE cluster. |
| `public_nat_ips` | Public static IP of nat gateway(s) |