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

### Fields

- `max_nodes` -- Optional. Default = 15
- `min_nodes` -- Optional. Default = 3
- `node_disk_size` -- Optional. Default = 20
- `node_instance_type` -- Optional. Default = t3.medium
- `uge_gpu` -- Optional. Default = false
- `spot_instances` -- Optional. Default = false

### Outputs

None
