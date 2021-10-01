---
title: "k8s-cluster"
linkTitle: "k8s-cluster"
date: 2021-07-21
draft: false
weight: 1
description: Creates a GKE cluster and a default nodegroup to host your applications in
---

This module creates a [GKE cluster](https://cloud.google.com/kubernetes-engine/docs/concepts/kubernetes-engine-overview), and a default
node pool to host your applications in. This needs to be added in the environment Opta yml if you wish to deploy services
as Opta services run on Kubernetes.

## Fields


| Name      | Description | Default | Required |
| ----------- | ----------- | ------- | -------- |
| `max_nodes` | The maximum number of nodes to be set by the autoscaler in for the default nodegroup. | `5` | False |
| `min_nodes` | The minimum number of nodes to be set by the autoscaler in for the default nodegroup. | `1` | False |
| `node_disk_size` | The size of disk to give the nodes' vms in GB. | `20` | False |
| `node_instance_type` | The [gcloud machine type](https://cloud.google.com/compute/docs/machine-types) for the nodes. | `n2-highcpu-4` | False |
| `gke_channel` | The GKE K8s [release channel](https://cloud.google.com/kubernetes-engine/docs/concepts/release-channels) to bind the cluster too. Gives you automatic K8s version management for the lcuster and node pools. | `REGULAR` | False |

## Outputs


| Name      | Description |
| ----------- | ----------- |
| `k8s_endpoint` | The endpoint to communicate to the kubernetes cluster through. |
| `k8s_ca_data` | The certificate authority used by the kubernetes cluster for ssl. |
| `k8s_cluster_name` | The name of the kubernetes cluster. |