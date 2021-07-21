---
title: "k8s-cluster"
linkTitle: "k8s-cluster"
date: 2021-07-21
draft: false
weight: 1
description: Creates a GKE cluster and a default nodegroup to host your applications in
---

This module creates a [GKE cluster](https://cloud.google.com/kubernetes-engine/docs/concepts/kubernetes-engine-overview), and a default
node pool to host your applications in. This needs to be added in the environment opta yml if you wish to deploy services
as opta services run on Kubernetes.

_Fields_

- `min_nodes` -- Optional. The minimum number of nodes to be set by the autoscaler in for the default nodegroup. Defaults to 3.
- `max_nodes` -- Optional. The minimum number of nodes to be set by the autoscaler in for the default nodegroup. Defaults to 5.
- `node_disk_size` -- Optional. The size of disk to give the nodes' ec2s. Defaults to 20(GB)
- `node_instance_type` -- Optional. The [gcloud machine type](https://cloud.google.com/compute/docs/machine-types) for the nodes. Defaults
  to n2-highcpu-4 (highly unrecommended to set to smaller)
- `gke_channel` -- Optional. The GKE K8s [release channel](https://cloud.google.com/kubernetes-engine/docs/concepts/release-channels)
  to bind the cluster too. Gives you automatic K8s version management for the lcuster and node pools. Defaults to "REGULAR"
