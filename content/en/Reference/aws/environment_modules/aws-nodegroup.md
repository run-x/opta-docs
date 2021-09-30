---
title: "aws-nodegroup"
linkTitle: "aws-nodegroup"
date: 2021-07-21
draft: false
weight: 1
description: Creates an additional nodegroup for the primary EKS cluster.
---

This module creates an additional nodegroup for the primary EKS cluster. Note that the
`aws-eks` module creates a default nodegroup so this should only be used when
you want one more.


## Fields


| Name      | Description | Default | Required |
| ----------- | ----------- | ------- | -------- |
| `labels` | labels for the kubernetes nodes | `{}` | False |
| `max_nodes` | Max number of nodes to allow via autoscaling | `15` | False |
| `min_nodes` | Min number of nodes to allow via autoscaling | `3` | False |
| `node_disk_size` | The size of disk to give the nodes' ec2s in GB. | `20` | False |
| `node_instance_type` | he [ec2 instance type](https://aws.amazon.com/ec2/instance-types/) for the nodes. | `t3.medium` | False |
| `use_gpu` | Should we expect and use the gpus present in the ec2? | `False` | False |
| `spot_instances` | A boolean specifying whether to use [spot instances](https://aws.amazon.com/ec2/spot/) for the default nodegroup or not. The spot instances will be configured to have the max price equal to the on-demand price (so no danger of overcharging). _WARNING_: By using spot instances you must accept the real risk of frequent abrupt node terminations and possibly (although extremely rarely) even full blackouts (all nodes die). The former is a small risk as containers of Opta services will be automatically restarted on surviving nodes. So just make sure to specify a minimum of more than 1 containers -- Opta by default attempts to spread them out amongst many nodes. The former is a graver concern which can be addressed by having multiple node groups of different instance types (see aws nodegroup module) and ideally at least one non-spot.  | `False` | False |