---
title: "gcp-nodepool"
linkTitle: "gcp-nodegpool"
date: 2021-07-21
draft: false
weight: 1
description: Creates an additional nodepool for the primary GKE cluster.
---

This module creates an additional nodepool for the primary GKE cluster. Note that the
`gcp-gke` module creates a default nodepool so this should only be used when
you want one more.


## Fields


| Name      | Description | Default | Required |
| ----------- | ----------- | ------- | -------- |
| `max_nodes` | The maximum number of nodes to be set by the autoscaler in for the default nodegroup. | `5` | False |
| `min_nodes` | The minimum number of nodes to be set by the autoscaler in for the default nodegroup. | `1` | False |
| `node_disk_size` | The size of disk to give the nodes' vms in GB. | `20` | False |
| `node_instance_type` | The [gcloud machine type](https://cloud.google.com/compute/docs/machine-types) for the nodes. | `n2-highcpu-4` | False |
| `gke_channel` | The GKE K8s [release channel](https://cloud.google.com/kubernetes-engine/docs/concepts/release-channels) to bind the cluster too. Gives you automatic K8s version management for the cluster and node pools. | `REGULAR` | False |
| `preemptible` | A boolean specifying whether to use [preemptible instances](https://cloud.google.com/compute/docs/instances/preemptible) for the default nodegroup or not. The preemptible instances will be configured to have the max price equal to the on-demand price (so no danger of overcharging). _WARNING_: By using preemptible instances you must accept the real risk of frequent abrupt node terminations and possibly (although extremely rarely) even full blackouts (all nodes die). The former is a small risk as containers of Opta services will be automatically restarted on surviving nodes. So just make sure to specify a minimum of more than 1 containers -- Opta by default attempts to spread them out amongst many nodes.  | `False` | False |