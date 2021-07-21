---
title: "base"
linkTitle: "base"
date: 2021-07-21
draft: false
weight: 1
description: Sets up virtual network, private subnet, security groups (and their rules), default encryption key vault, and the container registry
---

This module is the "base" module for creating an environment in azure. It sets up the virtual network, private subnet,
security groups (and their rules), default encryption key vault, and the container registry. Defaults are set to work
99% of the time, assuming no funny networking constraints (you'll know them if you have them), so
_no need to set any of the fields or know what the outputs do_.

### Fields

- `private_ipv4_cidr_block` -- Optional. This is the cidr block for VM instances in the VPC. Defaults to "10.0.0.0/16"
- `subnet_ipv4_cidr_block` -- Optional. This is the cidr block reserved for the subnet usage by the vm or private links. Defaults to "10.0.0.0/17"

### Outputs

- `vpc_id` -- The ID of the [Azure virtual network](https://docs.microsoft.com/en-us/azure/virtual-network/virtual-networks-overview) we created for this environment
- `private_subnet_id` -- The ID of the private [subnet](https://docs.microsoft.com/en-us/azure/virtual-network/virtual-network-manage-subnet)
  we setup for your environment
- `acr_id` -- The ID of the [Azure container registry](https://azure.microsoft.com/en-us/services/container-registry/) created for this environment
- `acr_name` --The name of the Azure container registry
- `acr_login_url` -- The login url of the Azure container registry.
