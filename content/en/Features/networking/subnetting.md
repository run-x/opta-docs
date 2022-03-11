---
title: "Subnetting"
linkTitle: "Subnetting"
date: 2022-03-11
weight: 5
draft: false
description: >
  How the network is partionned
---

## Subnetting

By default, Opta configure subnetting using some default values that would work for most of the users. This is a common piece of networking that if misconfigured could lead to running out of IPs when scaling the infrastructure. Such limitations would usually require to entirely rebuild the VPC, which would be very complex as it would require to recreate most of the cloud infrastructure in the new VPC.


**Why do we need so many IPs?**

The Kubernetes networking model relies heavily on IP addresses. Services, Pods, containers, and nodes communicate using IP addresses and ports. For a micro-service architecture, this will result in using a large number of IPs. For this reason, Opta has a default subnetting configuration capable of handling thousands of IPs. 


By default, Opta use the following CIDR:

### AWS

- VPC 10.0.0.0/16, 65,536 but it comes to 12,288 usable IPs because of availability zone restrictions.
- For public subnets AZs, 10.0.0.0/21 2,048 IPs, 10.0.8.0/21 2,048 IPs, 10.0.16.0/21 2,048 IPs. They are used only with public facing resources such as NAT Gateway, Load Balancers.
- For private subnets AZs, 10.0.128.0/21 2,048 IPs, 10.0.136.0/2 2,048 IPs, 10.0.144.0/21 2,048 IPs. They are used for everything else, ex: kubernetes workloads.

### GCP

- VMs 10.0.0.0/19 - 8,192 IPs
- k8s pods 10.0.32.0/19  - 8,192 IPs
- k8s services 10.0.64.0/20 - 4,096 IPs
- k8s master - 10.0.80.0/28 - 13 IPs (number of clusters - AWS limitation)

### Azure

- VPC IPs: 10.0.0.0/16 65,536 IPs
- Private subnet: 10.0.0.0/17 32,768 IPs.

### Configure the IP range

It is possible to set these IP ranges in the *base* module configuration.
