---
title: "k8s-cluster"
linkTitle: "k8s-cluster"
date: 2021-07-21
draft: false
weight: 1
description: Creates an EKS cluster and a default nodegroup to host your applications in
---

This module creates an [EKS cluster](https://docs.aws.amazon.com/eks/latest/userguide/what-is-eks.html), and a default
nodegroup to host your applications in. This needs to be added in the environment Opta yml if you wish to deploy services
as Opta services run on Kubernetes.

### Fields

- `min_nodes` -- Optional. The minimum number of nodes to be set by the autoscaler in for the default nodegroup. Defaults to 3.
- `max_nodes` -- Optional. The maximum number of nodes to be set by the autoscaler in for the default nodegroup. Defaults to 5.
- `node_disk_size` -- Optional. The size of disk to give the nodes' ec2s. Defaults to 20(GB)
- `node_instance_type` -- Optional. The [ec2 instance type](https://aws.amazon.com/ec2/instance-types/) for the nodes. Defaults
  to t3.medium (highly unrecommended to set to smaller)
- `k8s_version` -- Optional. The Kubernetes version for the cluster. Must be [supported by EKS](https://docs.aws.amazon.com/eks/latest/userguide/kubernetes-versions.html)
- `spot_instances` -- Optional. A boolean specifying whether to use [spot instances](https://aws.amazon.com/ec2/spot/)
  for the default nodegroup or not. The spot instances will be configured to have the max price equal to the on-demand
  price (so no danger of overcharging). _WARNING_: By using spot instances you must accept the real risk of frequent abrupt
  node terminations and possibly (although extremely rarely) even full blackouts (all nodes die). The former is a small
  risk as containers of Opta services will be automatically restarted on surviving nodes. So just make sure to specify
  a minimum of more than 1 containers -- Opta by default attempts to spread them out amongst many nodes. The former
  is a graver concern which can be addressed by having multiple node groups of different instance types (see aws
  nodegroup module) and ideally at least one non-spot. Default false

### Outputs

None
